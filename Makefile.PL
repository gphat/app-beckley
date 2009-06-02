use inc::Module::Install;

name 'App-Beckley';
all_from 'lib/App/Beckley.pm';

requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::SubRequest';
requires 'Catalyst::Runtime' => '5.7014';
requires 'Catalyst::View::JSON';

requires 'CGI';
requires 'CSS::Minifier::XS';
requires 'Data::Dumper';
requires 'Data::UUID';
requires 'DateTime::Format::HTTP';
requires 'DBIx::Class';
requires 'DBIx::Class::TimeStamp';
requires 'File::DigestStore';
requires 'File::Type';
requires 'File::Temp';
requires 'HTTP::Date';
requires 'Imager';
requires 'IO::File';
requires 'JSON::XS';
requires 'LWP';
requires 'URI';

requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
