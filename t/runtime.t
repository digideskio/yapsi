use v6;

use Test;
plan *;

use Yapsi;

my $out;
my $clear = method ($out is rw:) { $out = '' }
my $io-collector = class { method say($i) {$out ~= $i ~ "\n"} };

my Yapsi::Compiler $compiler .= new;
my Yapsi::Runtime $runtime .= new( :io($io-collector) );

my @tests =
    'say 42',                          "42\n",      'printing',
    'my $a = 42; say $a',              "42\n",      'variables',
    'my $a = 5; my $b = $a; say $b',   "5\n",       'assignment',
    'my $b := my $a; $a = 7; say $b',  "7\n",       'binding',
    'my $a := 42; say $a',             "42\n",      'bind a literal',
    'say my $a',                       "Any()\n",   'uninitialized',
    'say say 42',                      "42\n1\n",   'return value of say',
    'my $a = 42; my $a; say $a',       "42\n",      'same scope, same var',
    'my $a = 42; say ++$a',            "43\n",      'prefix increment',
    'my $a; say ++$a',                 "1\n",       'increment undefined',
    'my $a = 42; { say $a }',          "42\n",      'variable in a block',
    'my $a = 42; { say my $a }',       "Any()\n",   'new variable in a block',
    'my $a; { $a = 42 }; say $a',      "42\n",      'value survives block',
    'my $a = 42; {my $a = 7}; say $a', "42\n",
                'initialised value survives block',
    '{}; my $a = 42; { say $a }',      "42\n",      'same-level blocks',
    'if 42 { say 5 }',                 "5\n",       'executing if block',
    'if 0 { say 5 }',                  "",          'non-executing if block',
    'if 0 {} else { say 42 }',         "42\n",      'executing else block',
    'if 5 {} else { say 42 }',         "",          'non-executing else block',
    'my $a = 4; while --$a { say $a }',
                                       "3\n2\n1\n", 'while loop',
    'my $a; while $a { say 42 }',      "",          'non-executing while loop',
    'my $a = 42;unless $a { say 24 }', "",          'non-executing unless',
    'unless 0 { say 42 }',             "42\n",      'executing unless',
    'my $a=0; until $a { say 42; ++$a; }',
                                       "42\n",      'until loop',
    'until 42 { say 24; }',            "",          '0-itertion until loop',
    'my $a = 3; while --$a { say my $b; $b = 42 }', "Any()\nAny()\n",
                'each time a block is entered, it gets a fresh lexical pad',
    'my $a = 42; { { say $a; } }',     "42\n",      'var lookup >1 block up',
    'our $a; { my $a = 1; { our $a; $a = 5 } }; say $a',
                                       "5\n",       'our lookup',
    'my $a = 0; my $b = 0; until $a { if $b { $a = 1 }; say ++$b }',
                                       "1\n2\n",    'nested jumps in SIC',
    'my $a = { say 42 }; say 1; $a()', "1\n42\n",   'non-immediate block',
    'my $a := { say 2 }; say 1; $a()', "1\n2\n",    'bind block and call',
    '{ say 42 }()',                    "42\n",      'call a block',
    'sub foo { say 42 }; foo()',       "42\n",      'call a named sub',
    'foo(); sub foo { say 5 }',        "5\n",       'call before declaration',
    'sub foo { bar; sub bar { say 42 } }; foo',
                                       "42\n",      'nested sub call',
    'say 2; ENTER { say 1 }; say 3',   "1\n2\n3\n", 'ENTER phaser',
;

for @tests -> $program, $expected, $message {
    $out.$clear;
    $runtime.run( $compiler.compile($program) );

    is $out, $expected, $message;
}

done;
