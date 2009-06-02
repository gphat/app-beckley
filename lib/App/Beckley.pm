package App::Beckley;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

our $VERSION = '0.01';

use Catalyst;

use parent 'Catalyst';

__PACKAGE__->setup(qw/ConfigLoader Static::Simple SubRequest/);

=head1 NAME

App::Beckley - Catalyst based asset storage and filtering

=head1 SYNOPSIS

    script/app_beckley_server.pl

=head1 DESCRIPTION

Beckley is a digital asset storage application that will fetch assets for you,
version them and allow filtering when retrieving them.

Beckley uses File::DigestStore as a storage backend and Imager for image
processing.

=head1 INSTALLATION

Beckley needs to know the path to use for File::DigestStore's storage.  This
should be setup as the 'store' key in the YAML file.  The path should already
exist and be writable by whatever user your webserver runs as.

Beckley's database can be deployed via the included deploy script located in
the scripts directory.

=head1 STORING ASSETS

Beckley will store an asset given the following URL:

  http://yourserver:port/store/url/$key?url=$url_escaped_url

The asset will be fetched from the URL specified and stored in the filestore
and recorded in Beckley's database and a UUID will be returned that can be
used to retrieve the asset later.

The $key is important as it allows you to retrieve an asset without the UUID.
This is how versioniong is achieved.  More in the RETRIEVE ASSETS section.

NOTE: If an asset's hash matches that of an existing asset, it is NOT stored
again.  The new asset entry will be pointed to the existing asset path.  This
is the nature of File::DigestStore.

=head1 RETRIEVING ASSETS

An asset may be retrieved by UUID with:

  http://yourserver:port/fetch/uuid/$uuid

This returns the exact asset that was stored in the transaction identified by
$uuid.

  http://yourserver.port/fetch/key/$key

This returns the B<most recent version of the asset stored with $key>.

=head1 FILTERS

Beckley allows you to filter the asset before it is returned to you.  At the
moment only image filters are in place.  You may use them with the following
syntax:

  ?p=transform&a=scale&v=w64

The B<p> parameter identifies the controller (short for process, hence the p),
B<a> identifies the actionand B<v> the value that will be passed to that action.
Each controller should include documentation defining the actions that are
available.

Filters may be chained like so:

  ?p=transform&a=scale&v=w64&p=filter&a=gaussian&v=2
  
The parameters will be used in the order provided.  In other words the first
v value (w64) will be used with the first p and a values.

=head1 OUTPUT

You may specify the output format with the 'format' parameter.  Output
formats are limited to those supported by your Imager installation.

=head1 MACROS

Macros may be specified in the YAML file for Beckley in the following format:

  macros:
    image:
      tiny:
        format: gif
          actions:
            - p: transform
              a: scale
              v: w75
      medium:
        format: gif
          actions:
           - p: transform
             a: scale
             v: w175
             
The macro 'tiny' will perform a scale action from the Transform controller
with a vale of w75 and output a gif.  Multiple actions may be specified in
a macro in the same way they are allowed in the URL parameters.

=head1 SEE ALSO

L<App::Beckley::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
