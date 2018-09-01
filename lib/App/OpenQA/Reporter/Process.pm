package App::OpenQA::Reporter::Process;
use 5.008001;
use strict; use warnings;
use feature 'say';
use utf8;

use Mojo::File;
use Mojo::JSON qw(decode_json);
use Data::Dump qw(pp);

require Exporter;
our (@ISA, @EXPORT);
@ISA    = qw(Exporter);
@EXPORT = qw(
  process_file
  process_dir
  merge_resources
);

sub process_file {
  my ($file, $r) = @_;

  return 0 if !defined($file) || !defined($r);

  my $i = Mojo::File->new($file);
  my $ice = $i->slurp;

  unless($ice) {
    $r->set_error('Error on read data');
    return 0;
  }
  my @cream = decode_json($ice);
  my ($ns, $ts) = (undef, undef);
  # say pp($cream);

  unless(defined($cream[0])) {
    $r->set_error('Invalid JSON content');
    return 0;
  }

  foreach( @{ $cream[0] } ) {
    if (exists $_->{needle}) {
      if (exists $_->{screenshot}) {
        $ns = $r->get_needle($_->{screenshot});
        if (exists $_->{result}) {
          $ns->add_result(
            $_->{result} eq "ok" ? "pass" :
            $_->{result} eq "fail" ? "failure" : "unknown");
        } else {
          $ns->add_result("unknown");
        }

        # Check max number of needles
        $ns->set_max_needles(scalar(@{$_->{needles}}));

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
    }
  }

  1;
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
        die "Error on process file $_";
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
      if (defined %{$$nn}{$_}) {
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

    $invalid += $_->get_invalid();

    for (keys %{ $$tt }) {
      if (defined %{$$tt}{$_}) {
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
