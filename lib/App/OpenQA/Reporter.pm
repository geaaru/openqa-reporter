package App::OpenQA::Reporter;
use 5.008001;
use strict; use warnings;
use utf8;

use App::Cmd::Setup -app;
use Mojo::Log;
use Data::Dump qw(pp);
use Package::Alias 'iron' => 'App::OpenQA::Reporter';

our $VERSION = "0.01";

my $singleton = undef;

sub global_opt_spec {
  (
    ['ignore-errors|i', "Continue with errors." ],
    ['log_level|l:s',   "Specify log level (debug, info, warn, error). Default warn."],
    ['log_file|L:s',    "Specify a logfile instead of STDOUT."],
    ['verbose|v',       "Verbose output." ],
  )
}

sub new {
  my $class = shift;
  $singleton ||= bless({
      'log' => Mojo::Log->new(level => 'warn'),
      'app' => undef,
      'verbose' => 0,
      'ignore_errors' => 0,
    }, $class);

  # Retrieve global options
  $singleton->{verbose} = 1 if (defined($singleton->global_options->{verbose}));
  $singleton->{ignore_errors} = 1 if (defined($singleton->global_options->{ignore_errors}));

  if (defined($singleton->global_options->{log_level})) {
    $singleton->{log}->level(
      $singleton->global_options->{log_level}
    );
  }

  if (defined($singleton->global_options->{log_file})) {
    $singleton->{log}->path(
      $singleton->global_options->{log_file}
    );
  }

  $singleton;
}

sub verbose {
  my $self = shift;
  $self->{verbose};
}

sub ignore_errors {
  my $self = shift;
  $self->{ignore_errors};
}

sub info {
  my $self = shift;
  my @msg = @_;
  $self->{log}->info(@msg) if $self->{verbose};
  1;
}

sub error {
  my $self = shift;
  my @msg = @_;
  $self->{log}->error(@msg) if $self->{verbose};
  1;
}

sub debug {
  my $self = shift;
  my @msg = @_;
  $self->{log}->debug(@msg) if $self->{verbose};
  1;
}

sub warn {
  my $self = shift;
  my @msg = @_;
  $self->{log}->warn(@msg) if $self->{verbose};
  1;
}

*man=\&new;

1;
__END__

=encoding utf-8

=head1 NAME

App::OpenQA::Reporter - It's new $module

=head1 SYNOPSIS

    use App::OpenQA::Reporter;

=head1 DESCRIPTION

App::OpenQA::Reporter is ...

=head1 LICENSE

Copyright (C) Geaaru.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Geaaru E<lt>geaaru@gmail.comE<gt>

=cut

