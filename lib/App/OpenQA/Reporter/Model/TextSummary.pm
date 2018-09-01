package App::OpenQA::Reporter::Model::TextSummary;
use 5.008001;
use strict; use warnings;
use utf8;

sub TextSummary::new {
  my $class = shift;
  my $name = shift;
  # 'zypper_up-21.txt: Found in 10 files | Pass: 1, Failure: 1, Unknown 8'
  my $self = {
    'name'    => $name,
    'n_files' => 1,
    'pass'    => 0,
    'failure' => 0,
    'unknown' => 0
  };

  bless($self, $class);
  $self;
}

sub TextSummary::add_result {
  my ($self, $res) = @_;
  return 0 unless(defined($res));
  return 0 unless(defined($self->{$res}));
  $self->{$res}++;
}

sub TexSummary::merge_result {
  my ($self, $res, $value) = @_;
  return 0 unless(defined($res));
  return 0 unless(defined($self->{$res}));
  return 0 if $value < 0;
  $self->{$res} += $value;
}

sub TextSummary::get_result {
  my ($self, $res) = @_;
  return 0 unless(defined($res));
  return 0 unless(defined($self->{$res}));
  $self->{$res};
}

sub TextSummary::get_name {
  my $self = shift;
  $self->{name};
}

sub TextSummary::merge_result {
  my ($self, $res, $value) = @_;
  return 0 unless(defined($res));
  return 0 unless(defined($self->{$res}));
  return 0 if $value <= 0;
  $self->{$res} += $value;
}


1;
