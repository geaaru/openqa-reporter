package App::OpenQA::Reporter::Command::mojo;
use Mojo::Server;
use Mojolicious::Renderer;
use App::OpenQA::Reporter -command;
use strict; use warnings;
use feature 'say';
use App::OpenQA::Reporter::Process qw(
  load_resources
  merge_resources
);
use Data::Dump qw(pp);

sub abstract { "Web Server Reports Frontend" }

sub description {
  "Start OpenQA WebUI and display reports results.";
}

sub opt_spec {
  return (
    [ "file|f:s@", "File to parse" ],
    [ "dir|d:s@", "Directory to parse" ],
    [ "url|u:s@", "Url to file to parse" ],
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
  my @resources = load_resources($opt);
  my ($needles, $texts, $invalid) = merge_resources(\@resources);

  my $server = Mojo::Server->new();

  my $app = $server->build_app(
    'App::OpenQA::Reporter::Mojo',
    'log' => iron->man->{log},
  );

  my %data = (
    'resources' => \@resources,
    'needles' => $needles,
    'texts' => $texts,
    'invalid' => $invalid
  );

  iron->man->set_data(\%data);

  @ARGV = @{ $args };

  my $path = defined($ENV{'OPENQA_REPORTER_WEBROOT'}) ?
    $ENV{'OPENQA_REPORTER_WEBROOT'} : '.';

  # Configure static directory
  my $static = $app->static;
  push @{ $static->paths }, join("", $path, '/public');

  # Configure templates directory
  my $renderer = $app->renderer->paths([
      join("", $path, '/templates')
  ]);

  $app->start();
}

1;
