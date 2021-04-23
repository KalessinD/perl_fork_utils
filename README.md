# perl_crypt_xxhash

### NAME

Crypt::xxHash - xxHash implementation for Perl

### SYNOPSIS

```perl
    use Crypt::xxHash qw/
            xxhash32 xxhash32_hex
            xxhash64 xxhash64_hex
            xxhash3_64bits xxhash3_64bits_hex
            xxhash3_128bits_hex /;

    my $hash = xxhash32( $data, $seed );
    my $hex  = xxhash32_hex( $data, $seed );

    my $hash_64 = xxhash64( $data, $seed );
    my $hex_64  = xxhash64_hex( $data, $seed );

    my $hash_64 = xxhash3_64bits( $data, $seed );
    my $hex_64  = xxhash3_64bits_hex( $data, $seed );

    my $hex_128 = xxhash3_128bits_hex( $data, $seed );
```

### DESCRIPTION

xxHash is a super fast algorithm that claims to work at speeds close to RAM limits.
This package provides 32- and 64-bit hash functions.
As bonus it provides 128-bit hex method.

This package was inspired by "Digest::xxHash", but it includes the fresh C code and has
some optimisations. Thus all hex methods are implemented in Perl XS.
Also this module doesn't use "Math::Int64" in favor of native 64 bit digits.

##### $h = xxhash32( $data, $seed )

Returns a 32 bit hash.

##### $h = xxhash32_hex( $data, $seed )

Returns a 32 bit hash converted into hex string.

##### $h = xxhash64( $data, $seed )

Returns a 64 bit hash.

=head2 $h = xxhash64_hex( $data, $seed )

Returns a 64 bit hash converted into hex string

##### $h = xxhash3_64bits( $data, $seed )

Returns a 64 bit hash which calculated by using xxHash3 algorithm.

##### $h = xxhash3_64bits_hex( $data, $seed )

Returns a 64 bit hash which calculated by using xxHash3 algorithm.
This hash is converted into hex string.

##### $h = xxhash3_128its_hex( $data, $seed )

Returns a 128 bit hash which calculated by using xxHash3 algorithm.
This hash is converted into hex string.

### SPEED

There are some official benchmark results can be found on the project
web-site L<https://github.com/Cyan4973/xxHash>

### Benchmarks

Below you can find some benchmarks in comparison with C<Digest::xxHash>.

The "xxhash32" methods in those two packages have the same realisation.
so they have the same throughput capacity.

But other methods have some differences:

```
                                  Rate Digest::xxHash::xxhash32_hex Crypt::xxHash::xxhash32_hex
Digest::xxHash::xxhash32_hex 2577320/s                           --                        -54%
Crypt::xxHash::xxhash32_hex  5543237/s                         115%                          --

                               Rate Digest::xxHash::xxhash64 Crypt::xxHash::xxhash64
Digest::xxHash::xxhash64   201729/s                       --                    -99%
Crypt::xxHash::xxhash64  14893617/s                    7283%                      --

                                  Rate Digest::xxHash::xxhash64_hex Crypt::xxHash::xxhash64_hex
Digest::xxHash::xxhash64_hex  185048/s                           --                        -96%
Crypt::xxHash::xxhash64_hex  4926108/s                        2562%                          --
```

### LICENSE

xxHash is covered by the BSD license.

### AUTHOR

Chernenko Dmitiry cdn@cpan.org

xxHash by Yann Collet.
