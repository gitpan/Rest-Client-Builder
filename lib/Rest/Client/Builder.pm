package Rest::Client::Builder;

use strict;
use warnings;

our $VERSION = '0.02';
our $AUTOLOAD;

sub new {
	my ($class, $opts, $path) = @_;

	return bless({
		on_request => $opts->{on_request},
		path => defined $path ? $path : '',
		opts => { %$opts },
	}, $class);
}

sub _construct {
	my ($self, $path) = (shift, shift);

	my $id = $path;
	my $class = ref($self) . '::' . $path;

	if (defined $self->{path}) {
		$path = $self->{path} . '/' . $path;
	}

	if (@_) {
		my $tail = '/' . join('/', @_);
		$id .= $tail;
		$path .= $tail;
	}

	unless ($self->{objects}->{$id}) {
		$self->{objects}->{$id} = bless(Rest::Client::Builder->new($self->{opts}, $path), $class);
	}

	no strict 'refs';
	push @{$class . '::ISA'}, ref($self);

	return $self->{objects}->{$id};
}

sub AUTOLOAD {
	my $self = shift;

	(my $method = $AUTOLOAD) =~ s{.*::}{};
	return undef if $method eq 'DESTROY';
	no strict 'refs';
	my $ref = ref($self);

	*{$ref . '::' . $method} = sub {
		my $self = shift;
		$self->_construct($method, @_);
	};

	return $self->$method(@_);
}

sub get {
	my ($self, $args) = @_;
	return $self->{on_request}->('GET', $self->{path}, $args);
}

sub post {
	my ($self, $args) = @_;
	return $self->{on_request}->('POST', $self->{path}, $args);
}

sub put {
	my ($self, $args) = @_;
	return $self->{on_request}->('PUT', $self->{path}, $args);
}

sub delete {
	my ($self, $args) = @_;
	return $self->{on_request}->('DELETE', $self->{path}, $args);
}

sub patch {
	my ($self, $args) = @_;
	return $self->{on_request}->('PATCH', $self->{path}, $args);
}

sub head {
	my ($self, $args) = @_;
	return $self->{on_request}->('HEAD', $self->{path}, $args);
}

1;

__END__

=head1 NAME

Rest::Client::Builder - Base class to build simple object-oriented REST clients

=head1 SYNOPSIS

	use Rest::Client::Builder;

	package Your::API::Class;
	use base qw(Rest::Client::Builder);
	use JSON;

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
		print sprintf("%s %s %s\n", $method, $path, encode_json($args));
	}

	my $api = Your::API::Class->new();
	$api->resource->get({ value => 1 });
	# output: GET http://hostname/api/resource {"value":1}

	$api->resource(10)->post({ value => 1 });
	# output: POST http://hostname/api/resource/10 {"value":1}

	$api->resource(10)->subresource('alfa', 'beta')->state->put({ value => 1 });
	# output: PUT http://hostname/api/resource/10/subresource/alfa/beta/state {"value":1}

	$api->resource(10)->delete->();
	# output: DELETE http://hostname/api/resource/10

=head1 SEE ALSO

L<WWW::REST>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc Rest::Client::Builder

You can also look for information at:

=over

=item * Code Repository at GitHub

L<http://github.com/alexey-komarov/Rest-Client-Builder>

=item * GitHub Issue Tracker

L<http://github.com/alexey-komarov/Rest-Client-Builder/issues>

=item * RT, CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Rest-Client-Builder>

=back

=head1 AUTHOR

Alexey A. Komarov <alexkom@cpan.org>

=head1 COPYRIGHT

2014 Alexey A. Komarov

=head1 LICENSE

This library is free software; you may redistribute it and/or modify it under the same terms as Perl itself.

=cut
