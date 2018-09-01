package App::OpenQA::Reporter::Model::Resource;
use App::OpenQA::Reporter::Model::NeedlesSummary;
use App::OpenQA::Reporter::Model::TextSummary;
use 5.008001;
use strict; use warnings;
use utf8;

sub Resource::new {
  my ($class, $type) = @_;
  my $self = {
    'type'    => $type,
    'needles' => {},
    'texts'   => {},
    'url'     => undef,
    'file'    => undef,
    'error'   => undef,
    'invalid' => 0
  };

  bless($self, $class);
  $self;
}

sub Resource::add_invalid {
  my $self = shift;
  ++$self->{invalid};
}

sub Resource::get_invalid {
  my $self = shift;
  $self->{invalid};
}

sub Resource::set_file {
  my ($self, $f) = @_;
  return 0 unless($f);
  $self->{file} = $f;
  1;
}

sub Resource::set_url {
  my ($self, $url) = @_;
  return 0 unless($url);
  $self->{url} = $url;
  1;
}

sub Resource::set_error {
  my ($self, $error) = @_;
  return 0 unless(defined($error));
  $self->{error} = $error;
  1;
}

sub Resource::get_needle {
  my ($self, $screenshot) = @_;
  my $ans;
  return 0 unless(defined($screenshot));

  if (defined($self->{needles}->{$screenshot})) {
    $ans = $self->{needles}->{$screenshot};
  } else {
    $ans = NeedlesSummary::->new(${screenshot});
    $self->{needles}->{$screenshot}=$ans;
  }
  $ans;
}

sub Resource::get_text {
  my ($self, $text) = @_;
  my $ans;
  return 0 unless(defined($text));

  if (defined($self->{texts}->{$text})) {
    $ans = $self->{texts}->{$text};
  } else {
    $ans = TextSummary::->new($text);
    $self->{texts}->{$text} = $ans;
  }
  $ans;
}

sub Resource::get_needles {
  my $self = shift;
  return 0 unless(defined($self));
  return \$self->{needles};
}

sub Resource::get_texts {
  my $self = shift;
  return 0 unless(defined($self));
  \$self->{texts};
}

sub Resource::get_url {
  my $self = shift;
  $self->{url};
}

sub Resource::get_type {
  my $self = shift;
  $self->{type};
}

sub Resource::get_file {
  my $self = shift;
  $self->{file};
}

sub Resource::get_error {
  my $self = shift;
  $self->{error};
}

1;
