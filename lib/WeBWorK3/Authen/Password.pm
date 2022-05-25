package WeBWorK3::Authen::Password;

use strict;
use warnings;
use feature 'signatures';
no warnings qw(experimental::signatures);

use base qw/Crypt::PBKDF2/;

sub new ($invocant, %params) {
	my $class = ref $invocant || $invocant;
	return bless $class->SUPER::new(
		hash_class => 'HMACSHA2',
		hash_args  => { sha_size => 512 },
		iterations => 10000,
		salt_len   => 16,
		%params
	), $class;
}

1;
