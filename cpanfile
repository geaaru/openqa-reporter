requires 'perl';
requires 'App::Cmd';
requires 'Data::Dump';
requires 'LWP::Simple';
requires 'Package::Alias';
requires 'Mojo::Log';
requires 'Mojo::JSON';
requires 'Mojo::File';
requires 'Mojolicious::Lite';


on 'test' => sub {
    requires 'Test::More', '0.98';
};

