use strict;
use warnings;

use Rest::Client::Builder;

package Your::API::Class;
use base qw(Rest::Client::Builder);

use Test::More tests => 6;

sub new {
my ($class) = @_;
	my $self;
	$self = $class->SUPER::new({
		on_request => sub {
			return $self->request(@_);
		},
	}, 'http://hostname/api');

	return bless($self, $class);
};

sub request {
	my ($self, $method, $path, $args) = @_;
	return sprintf('%s %s %s', $method, $path, $args ? $args->{value} : 'undef');
}

my $api = Your::API::Class->new();

my $result = $api->resource->get({ value => 1 });
ok($result eq 'GET http://hostname/api/resource 1', 'get');

$result = $api->resource(10)->post({ value => 1 });
ok($result eq 'POST http://hostname/api/resource/10 1', 'post');

$result = $api->resource(10)->subresource('alfa', 'beta')->state->put({ value => 1 });
ok($result eq 'PUT http://hostname/api/resource/10/subresource/alfa/beta/state 1', 'put');

$result = $api->resource(10)->subresource('alfa', 'beta')->delete();
ok($result eq 'DELETE http://hostname/api/resource/10/subresource/alfa/beta undef', 'delete');

$result = $api->resource(10, 1, 2)->child(1)->head();
ok($result eq 'HEAD http://hostname/api/resource/10/1/2/child/1 undef', 'head');

$result = $api->resource(10)->something->patch({ value => 1 });
ok($result eq 'PATCH http://hostname/api/resource/10/something 1', 'patch');
