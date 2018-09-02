package App::OpenQA::Reporter::Process;
use 5.008001;
use strict; use warnings;
use feature 'say';
use utf8;

use App::OpenQA::Reporter::Model::Resource;
use Mojo::File;
use Mojo::JSON qw(decode_json);
use Data::Dump qw(pp);
use LWP::Simple;

require Exporter;
our (@ISA, @EXPORT);
@ISA    = qw(Exporter);
@EXPORT = qw(
  load_resources
  process_dir
  process_file
  process_url
  merge_resources
);

sub load_resources {
  my ($opt) = @_;
  my @resources = ();

  if (defined($opt->{file})) {
    foreach (@{ $opt->{file} }) {
      iron->man->debug("Processing file $_...");
      my $r = Resource::->new('file');
      $r->set_file($_);
      push @resources, $r;
      unless (process_file($_, $r)) {
        iron->man->error(
          join("", "Error on process file $_: ", $r->get_error())
        );
        die "Error on process file $_"
          unless(iron->man->ignore_errors());
      }
      iron->man->debug("File $_: ", pp($r));
    }
  }

  if (defined($opt->{url})) {
    foreach (@{ $opt->{url} }) {
      iron->man->debug("Processing url $_...");
      my $r = Resource::->new('url');
      $r->set_url($_);
      push @resources, $r;
      unless (process_url($_, $r)) {
        iron->man->error(
          join("", "Error on process url $_: ", $r->get_error())
        );
        die "Error on process url $_"
          unless(iron->man->ignore_errors());
      }
      iron->man->debug("Url $_: ", pp($r));
    }
  }


  if (defined($opt->{dir})) {
    foreach (@{ $opt->{dir} }) {
      iron->man->info("Processing directory $_...");
      unless (process_dir($_, \@resources)) {
        die "Error on process directory $_"
          unless(iron->man->ignore_errors());
        iron->man->error(
          "Error on processing directory $_."
        );
      }
    }
  }

  return @resources;
}

sub process_json {
  my ($ice, $r) = @_;

  my ($ns, $ts) = (undef, undef);
  my @cream;
  eval { @cream = decode_json($$ice) } ;
  # say pp($cream);

  unless(defined($cream[0])) {
    $r->set_error('Invalid JSON content');
    return 0;
  }

  foreach( @{ $cream[0] } ) {
    if (exists $_->{needle}) {
      if (exists $_->{screenshot}) {
        $ns = $r->get_needle($_->{screenshot});

        for my $area (@{$_->{area}}) {
          if (exists $area->{result}) {
            $ns->add_result(
              $area->{result} eq "ok" ? "pass" :
              $area->{result} eq "fail" ? "failure" : "unknown");
          } else {
            $ns->add_result("unknown");
          }
        }

        if (exists $_->{needles}) {
          # Check max number of needles
          $ns->set_max_needles(scalar(@{$_->{needles}}));

          # Get area under needles
          for my $needle (@{$_->{needles}}) {
            for my $area (@{$needle->{area}}) {
              if (exists $area->{result}) {
                $ns->add_result(
                  $area->{result} eq "ok" ? "pass" :
                  $area->{result} eq "fail" ? "failure" : "unknown");
              } else {
                $ns->add_result("unknown");
              }
            }

          }
        }

      } else {
        # POST: invalid object
        $r->add_invalid();
      }

    } elsif (exists $_->{text}) {
      $ts = $r->get_text($_->{text});
      if (exists $_->{result}) {
        $ts->add_result(
          $_->{result} eq "ok" ? "pass" :
          $_->{result} eq "fail" ? "failure" : "unknown");
      } else {
        $ts->add_result("unknown");
      }
    } else {
      $r->add_invalid();
      iron->man->debug('Skip invalid object (without needle/text): ', pp($_));
    }
  }

  1;
}

sub process_file {
  my ($file, $r) = @_;

  return 0 if !defined($file) || !defined($r);

  my $i = Mojo::File->new($file);
  my $ice = $i->slurp;

  unless($ice) {
    $r->set_error('Error on read data');
    return 0;
  }

  return process_json(\$ice, $r);
}

sub process_url {
  my ($url, $r) = @_;

  return 0 if !defined($url) || !defined($r);

  my $ice = get($url);

  unless($ice) {
    $r->set_error("Error on retrieve data from url.");
    return 0;
  }

  return process_json(\$ice, $r);
}

sub process_dir {
  my ($dir, $resources) = @_;
  my $d;
  my $files = 0;

  return 0 unless (defined($dir));
  return 0 unless (defined($resources));

  $dir = substr($dir, 0, length($dir)-1) unless substr($dir, -1) cmp "/";

  opendir($d, $dir) || return 0;

  my @files = readdir($d);
  foreach (@files) {
    if ($_ =~ /.json$/) {
      $files++;
      my $r = Resource::->new('file');
      $r->set_file($_);
      push @{$resources}, $r;
      unless (process_file("${dir}/$_", $r)) {
        iron->man->error(
          join("", "Error on process file $_: ", $r->get_error())
        );
        die "Error on process file $_"
          unless(iron->man->ignore_errors());
      }
    }
  }
  closedir($d);

  1;
}

sub merge_resources {
  my ($resources) = @_;
  my %needles = ();
  my %texts = ();
  my $invalid = 0;
  my $i = 0;
  my $r;

  for (@{ $resources }) {
    my $nn = $_->get_needles();
    my $tt = $_->get_texts();
    $invalid += $_->get_invalid();
    # NOTE: For now permit to use some files more times
    #       for easy test.
    unless ($i++) {
      for (keys %{ $$nn }) {
        $needles{$_} = %{$$nn}{$_};
      }
      for (keys %{ $$tt }) {
        $texts{$_} = %{$$tt}{$_};
      }

      #pp(%needles);
      next;
    }

    for (keys %{ $$nn }) {
      if (defined $needles{$_}) {
        $needles{$_}->add_result('n_files');
        for my $p (qw( pass failure unknown)) {
          $needles{$_}->merge_result($p,
            %{$$nn}{$_}->get_result($p));
        }
        $needles{$_}->set_max_needles(%{$$nn}{$_}->get_max_needles())
          if $needles{$_}->get_max_needles() lt %{$$nn}{$_}->get_max_needles();
      } else {
        $needles{$_} = %{$$nn}{$_};
      }
    }

    for (keys %{ $$tt }) {
      if (defined $texts{$_}) {
        $texts{$_}->add_result('n_files');
        for my $p (qw( pass failure unknown)) {
          $texts{$_}->merge_result($p,
            %{$$tt}{$_}->get_result($p));
        }
      } else {
        $texts{$_} = %{$$tt}{$_};
      }
    }
  }

  return \%needles, \%texts, $invalid;
}

1;
