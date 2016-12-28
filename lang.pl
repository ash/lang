use lib '.';
use Lang::Grammar;
use Lang::Actions;

my $parsed = Lang::Grammar.parsefile(@*ARGS[0] // 'test.lang', :actions(Lang::Actions.new()));
