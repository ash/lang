my %var;

grammar Lang {
    rule TOP {
        ^ <statements> $
    }
    rule statements {
        <statement>+ %% ';'
    }
    rule statement {
        | <assignment>
        | <printout>
    }
    rule assignment {
        <identifier> '=' <expression>
    }
    rule printout {
        'print' <expression>
    }
    rule expression {
        | <term>+ %% $<op>=(['+'|'-'])
        | <group>
    }
    rule term {
        <factor>+  %% $<op>=(['*'|'/'])
    }
    rule factor {
        | <identifier>
        | <value>
        | <group>
    }
    rule group {
        '(' <expression> ')'
    }
    token identifier {
        (<:alpha>+)
    }
    token value {
        (
            | \d+['.' \d+]*
            | '.' \d+
        )
    }
}

class LangActions {
    method assignment($/) {
        %var{$<identifier>} = $<expression>.ast;
    }

    method printout($/) {
        say $<expression>.ast;
    }

    method expression($/) {
        if $<group> {
            $/.make: $<group>.ast
        }
        else {
            my $result = $<term>[0].ast;

            if $<op> {
                my @ops = $<op>.map(~*);
                my @vals = $<term>[1..*].map(*.ast);

                for 0..@ops.elems - 1 -> $c {
                    if @ops[$c] eq '+' {
                        $result += @vals[$c];
                    }
                    else {
                        $result -= @vals[$c];
                    }
                }
            }

            $/.make: $result;
        }
    }

    method term($/) {
        my $result = $<factor>[0].ast;

        if $<op> {
            my @ops = $<op>.map(~*);
            my @vals = $<factor>[1..*].map(*.ast);

            for 0..@ops.elems - 1 -> $c {
                if @ops[$c] eq '*' {
                    $result *= @vals[$c];
                }
                else {
                    $result /= @vals[$c];
                }
            }
        }

        $/.make: $result;
    }

    method factor($/) {
        if $<identifier> {
            $/.make: %var{~$<identifier>} // 0
        }
        elsif $<value> {
            $/.make: $<value>.ast
        }
        elsif $<group> {
            $/.make: $<group>.ast
        }
    }

    method group($/) {
        $/.make: $<expression>.ast
    }

    method identifier($/) {
        $/.make: ~$0
    }

    method value($/) {
        $/.make: +$0
    }
}

my $parsed = Lang.parsefile('test.lang', :actions(LangActions.new()));
#my $parsed = Lang.parse('x=42;print x', :actions(LangActions.new()));
#say $parsed.perl;
