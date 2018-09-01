requires 'perl';
requires 'App::Cmd';
requires 'LWP::Simple';


on 'test' => sub {
    requires 'Test::More', '0.98';
};

