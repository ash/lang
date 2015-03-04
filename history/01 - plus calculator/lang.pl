use lib '.';
use Lang::Grammar;
use Lang::Actions;

my $parsed = Lang::Grammar.parsefile('test.lang', :actions(Lang::Actions.new()));
