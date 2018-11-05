use combine::*;
use combine::parser::char::*;
use combine::combinator::*;

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Token {
    Id(String),
    String(Vec<Token>),
    IndString(Vec<Token>),
    Str(String),
    Round(Vec<Token>),
    Curly(Vec<Token>),
    Square(Vec<Token>),
    DollarCurly(Vec<Token>),
    Int(u64),
    Float(String), // no float equality
    Path(String),
    Uri(String),
    Comma, Dot, Semicolon, Colon, Equals,
    Ellipsis,
    
    Not,
    Eq, Neq, Lt, Gt, Geq, Leq,
    And, Or, Impl,
    Update, Question, OrKw,
    Plus, Minus, Multiply, Divide,
    Concat,
    
    If,
    Then,
    Else,
    Assert,
    With,
    Let,
    In,
    Rec,
    Inherit,
}

parser! {
    pub fn id_cont[I]()(I) -> char where [
        I: Stream<Item=char>,
    ] {
        char('\'').or(alpha_num())
    }
}

parser! {
    pub fn id[I]()(I) -> String where [
        I: Stream<Item=char>,
    ] {
        letter().and(many(id_cont()))
            .map(|(c, cs): (char, String)| {
                let mut s = c.to_string();
                s.push_str(&cs);
                s
            })
    }
}

parser! {
    pub fn keyword[I](kw: &'static str, ret: Token)(I) -> Token where [
        I: Stream<Item=char>,
    ] {
        attempt(string(&kw).and(not_followed_by(id_cont())))
            .map(move |_| ret.clone())
    }
}

parser! {
    pub fn named[I](tok: &'static str, ret: Token)(I) -> Token where [
        I: Stream<Item=char>,
    ] {
        attempt(string(tok)).map(move |_| ret.clone())
    }
}


parser! {
    pub fn int[I]()(I) -> u64 where [
        I: Stream<Item=char>,
    ] {
        from_str(many1::<String, _>(digit()))
    }
}

parser! {
    pub fn float[I]()(I) -> String where [
        I: Stream<Item=char>,
    ] {
        many1::<String, _>(digit())
            .and(char('.'))
            .and(many::<String, _>(digit()))
            .map(|((m, _), e)| format!("{}.{}", m, e))
    }
}

fn unescape(s: char) -> &'static str {
    match s {
        'r' => "\r",
        'n' => "\n",
        't' => "\t",
        '$' => "$",
        _ => panic!("invalid escape"),
    }
}

parser! {
    pub fn ind_str[I]()(I) -> Vec<Token> where [
        I: Stream<Item=char>,
    ] {
        let inert = (choice! {
            none_of("'$".chars()),
            attempt(char('\'').skip(not_followed_by(char('\'')))),
            attempt(char('$').skip(not_followed_by(char('{'))))
        }).map(|x: char| x.to_string());
        let interp = between(attempt(string("${")), string("}"), expr());
        let escape = choice! {
            attempt(string("'''")).map(|_| "''"),
            attempt(string("''$")).map(|_| "$"),
            attempt(string("''\\").with(any())).map(unescape)
        }.map(|x: &str| x.to_string());
        many(choice! {
            many1(inert.or(escape)).map(|xs: Vec<String>| { Token::Str(xs.into_iter().collect()) }),
            interp.map(Token::DollarCurly)
        })
    }
}

parser! {
    pub fn str_[I]()(I) -> Vec<Token> where [
        I: Stream<Item=char>,
    ] {
        let str_ = many1::<String, _>(choice! {
            none_of("\"$".chars()),
            attempt(char('$').skip(not_followed_by(char('{'))))
                .map(|x| {
                    println!("str_ done, got {:?}", x);
                    x
                })

        }).map(Token::Str);
        many::<Vec<Token>, _>(choice! {
            str_,
            between(attempt(string("${")), string("}"), expr()).map(Token::DollarCurly)
        })
    }
}

parser! {
    pub fn token[I]()(I) -> Token where [
        I: Stream<Item=char>,
    ] {
        (choice! {
            keyword("if", Token::If),
            keyword("then", Token::Then),
            keyword("else", Token::Else),
            keyword("assert", Token::Assert),
            keyword("with", Token::With),
            keyword("let", Token::Let),
            keyword("rec", Token::Rec),
            keyword("inherit", Token::Inherit),
            keyword("or", Token::OrKw),
            named("!", Token::Not),
            named("...", Token::Ellipsis),
            named("==", Token::Eq),
            named("!=", Token::Neq),
            named("<=", Token::Leq),
            named(">=", Token::Geq),
            named("&&", Token::And),
            named("||", Token::Or),
            named("->", Token::Impl),
            named("//", Token::Update),
            named("?", Token::Question),
            named("+", Token::Plus),
            named("-", Token::Minus),
            named("*", Token::Multiply),
            named("/", Token::Divide),
            named("++", Token::Concat),
            between(char('"'), char('"'), lazy(str_)).map(Token::String),
            between(attempt(string("''")), string("''"), lazy(ind_str)).map(Token::IndString),
            between(attempt(string("${")), char('}'), lazy(expr)).map(Token::DollarCurly),
            between(char('('), char(')'), expr()).map(Token::Round),
            between(char('['), char(']'), expr()).map(Token::Square),
            between(char('{'), char('}'), expr()).map(Token::Curly),
            named(".", Token::Dot),
            named(",", Token::Comma),
            named(":", Token::Colon),
            named(";", Token::Semicolon),
            named("=", Token::Equals),
            attempt(id()).map(|id| Token::Id(id)),
            attempt(float()).map(|x| Token::Float(x.to_string())),
            attempt(int()).map(|x| Token::Int(x))
        }).map(|x| { /* println!("got token: {:?}", x); */ x })
    }
}

parser! {
    pub fn expr[I]()(I) -> Vec<Token> where [
        I: Stream<Item=char>,
    ] {
        spaces().with(sep_end_by1(token(), spaces()).map(|x| {
            //println!("expr done; got {:?}", x);
            x
        }))
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use combine::stream::state::State;
    fn test(s: &'static str) -> () {
        println!("{:?}", expr().easy_parse(State::new(s)).expect("err: "))
    }
    #[test]
    fn foo() {
        test("a ++ b'");
        test("a1'++b2'");
        test("or ++ b");
        test("orb ++ b");
        test("{a, b}: {key= [val1 val2 17 0.75  ];}");
        test("\"foo bar  baz${{baz=\"quux\";}}other\"")
    }
}
