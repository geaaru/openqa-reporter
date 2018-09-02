package App::OpenQA::Reporter::Model::NeedlesSummary;
use 5.008001;
use strict; use warnings;
use utf8;

sub NeedlesSummary::new {
  my $class = shift;
  my $screenshot = shift;
  # zypper_up-2.png: Found in 10 files | Pass: 2, Failure: 7, Unknown 1 | Max of 5 needles found.
  return 0 unless ($screenshot);
  my $self = {
    'screenshot'  => $screenshot,
    'n_files'     => 1,
    'pass'        => 0,
    'failure'     => 0,
    'unknown'     => 0,
    'max_needles' => 0
  };

  bless($self, $class);
  $self;
}

sub NeedlesSummary::get_max_needles {
  my $self = shift;
  $self->{max_needles};
}

sub NeedlesSummary::set_max_needles {
  my ($self, $max) = @_;
  if ($max gt $self->{max_needles}) {
    $self->{max_needles} = $max;
  }
  1;
}

sub NeedlesSummary::merge_result {
  my ($self, $res, $value) = @_;
  return 0 unless(defined($res));
  return 0 unless(defined($self->{$res}));
  return 0 if $value <= 0;
  $self->{$res} += $value;
}

sub NeedlesSummary::add_result {
  my $self = shift;
  my $res = shift;

  return 0 unless(defined($res));
  return 0 unless(defined($self->{$res}));
  $self->{$res}++;
  1;
}

sub NeedlesSummary::get_result {
  my ($self, $res) = @_;

  return 0 unless(defined($self->{$res}));
  $self->{$res};
}

sub NeedlesSummary::get_screenshot {
  my $self = shift;
  $self->{screenshot};
}

1;
