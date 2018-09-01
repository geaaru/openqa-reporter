package App::OpenQA::Reporter::Command::parse;
use App::OpenQA::Reporter -command;
use strict; use warnings;
use feature 'say';
use App::OpenQA::Reporter::Model::NeedlesSummary;
use App::OpenQA::Reporter::Model::TextSummary;
use App::OpenQA::Reporter::Model::Resource;
use App::OpenQA::Reporter::Process qw(process_file process_dir merge_resources);
use Data::Dump qw(pp);

sub abstract { "Process OpenQA report(s)" }

sub description {
  "Process a file or a directory and produce a summary";
}

sub opt_spec {
  return (
    [ "file|f:s@", "File to parse" ],
    [ "dir|d:s@", "Directory to parse" ],
    [ "url|u:s@", "Url to file to parse" ],
    [ "quiet|q", "Quiet output" ],
  );
}

sub validate_args {
  my ($self, $opt, $args) = @_;

  my $has_url = defined $opt->{url} ? scalar(@{$opt->{url}}) : 0;
  my $has_dir = defined $opt->{dir} ? scalar(@{$opt->{dir}}) : 0;
  my $has_file = defined $opt->{file} ? scalar(@{$opt->{file}}) : 0;

  $self->usage_error("No url|file|dir supplied")
    unless $has_url || $has_dir || $has_file;
}

sub execute {
  my ($self, $opt, $args) = @_;
  my @resources = ();

  if (defined($opt->{file})) {
    foreach (@{ $opt->{file} }) {
      my $r = Resource::->new('file');
      $r->set_file($_);
      push @resources, $r;
      unless (process_file($_, $r)) {
        die "Error on process file $_";
      }
    }
  }

  if (defined($opt->{dir})) {
    foreach (@{ $opt->{dir} }) {
      unless (process_dir($_, \@resources)) {
        die "Error on process directory $_";
      }
    }
  }

  my ($needles, $texts, $invalid) = merge_resources(\@resources);

  say "Needles found:";
  foreach (sort keys (%{ $needles })) {
    say "$_: Found in ", %{ $needles }{$_}->get_result('n_files'),
      " files | Pass: ", %{ $needles }{$_}->get_result('pass'),
      ", Failure: ", %{ $needles }{$_}->get_result('failure'),
      ", Unknown: ", %{ $needles }{$_}->get_result('unknown'),
      " | Max of ", %{ $needles }{$_}->get_result('max_needles'),
      " needles found.";
  }
  say "";
  say "Text Found:";
  foreach (sort keys (%{ $texts })) {
    say "$_: Found in ", %{ $texts }{$_}->get_result('n_files'),
      " files | Pass: ", %{ $texts }{$_}->get_result('pass'),
      ", Failure: ", %{ $texts }{$_}->get_result('failure'),
      ", Unknown: ", %{ $texts }{$_}->get_result('unknown');
  }

  if ($invalid) {
    say "";
    say "Invalid JSON object Found: ", $invalid;
  }

  #pp(%{ $needles });

}

1;
