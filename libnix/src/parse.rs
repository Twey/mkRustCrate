use combine::*;
use combine::stream::Stream;
use combine::parser::char::*;

use crate::expr::*;

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
        letter()
            .and(many(id_cont()))
            .map(|(c, cs): (char, String)| {
                let mut s = c.to_string();
                s.push_str(&cs);
                s
            }).skip(spaces())
    }
}

parser! {
    pub fn keyword[I](kw: &'static str)(I) -> () where [
        I: Stream<Item=char>,
    ] {
        attempt(string(&kw).skip(not_followed_by(id_cont())))
            .skip(spaces())
            .map(drop)
    }
}

parser! {
    pub fn expr[I]()(I) -> Expr where [
        I: Stream<Item=char>,
    ] {
        spaces().with(expr_function())
    }
}

parser! {
    pub fn bindings[I]()(I) -> Bindings where [
        I: Stream<Item=char>,
    ] {
        let binding = choice! {
            // TODO normal binds
            keyword("inherit")
                .skip(spaces())
                .with(optional(
                    between(char('('), char(')').skip(spaces()), expr())))
                .and(sep_end_by(id(), spaces())) // TODO not quite right, attrs is more complicated than ids
                .map(|(source, attrs)| Binding::Inherit {
                    source: source.map(Box::new),
                    attrs
                })
        };
        sep_end_by(binding.skip(spaces()), char(';').skip(spaces()))
    }
}

parser! {
    pub fn expr_function[I]()(I) -> Expr where [
        I: Stream<Item=char>,
    ] {
        let formal_parameters = ||
            between(char('{').skip(spaces()),
                    char('}').skip(spaces()),
                    formals());
        let function_parameters = (choice! {
            formal_parameters()
                .and(optional(char('@').skip(spaces()).with(id())))
                .map(|(fs, n)| Pattern::Set {
                    name: n,
                    parameters: fs,
                }),
            attempt(id().skip(char('@')))
                .skip(spaces())
                .and(formal_parameters())
                .map(|(n, fs)| Pattern::Set {
                    name: Some(n),
                    parameters: fs,
                }),
            id().map(Pattern::Name)
        }).skip(spaces());
        (choice! {
            attempt(function_parameters.skip(char(':')))
                .skip(spaces())
                .and(expr_function())
                .map(|(p, e)| Expr::Bound(Bound {
                    binder: Binder::Function(p),
                    body: Box::new(e),
                })),
            keyword("assert")
                .with(expr())
                .skip(char(';'))
                .skip(spaces())
                .and(expr_function())
                .map(|(a, e)| {
                    Expr::Bound(Bound {
                        binder: Binder::Assert(Box::new(a)),
                        body: Box::new(e),
                    })
                }),
            keyword("let")
                .with(bindings())
                .skip(keyword("in"))
                .and(expr_function())
                .map(|(bs, e)| {
                    Expr::Bound(Bound {
                        binder: Binder::Let(bs),
                        body: Box::new(e),
                    })
                }),
            expr_if()
        }).skip(spaces())
    }
}

parser! {
    pub fn expr_if[I]()(I) -> Expr where [
        I: Stream<Item=char>,
    ] {
        (choice! {
            keyword("PLACEHOLDER").map(|_| Expr::Literal(Literal::Int(3))),
            keyword("if").with(expr())
                .skip(keyword("then")).and(expr())
                .skip(keyword("else")).and(expr())
                .map(|((p, t), f)| {
                    Expr::Conditional(Conditional {
                        cond: Box::new(p),
                        then_: Box::new(t),
                        else_: Box::new(f),
                    })
                })
        }).skip(spaces())
    }
}

parser! {
    pub fn expr_op[I]()(I) -> Expr where [
        I: Stream<Item=char>,
    ] {
        choice! {
            value(Expr::Literal(Literal::Int(5)))
        }
    }
}

parser! {
    pub fn formals[I]()(I) -> Vec<Parameter> where [
        I: Stream<Item=char>,
    ] {
        let parameter = choice! {
            string("...").skip(spaces()).map(|_| Parameter::Ellipsis),
            id().and(optional(spaces().skip(char('?')).with(expr())))
                .skip(spaces())
                .map(|(x, d)| Parameter::Named {
                    name: x,
                    default: d.map(Box::new),
                })
        };
        sep_by(parameter, char(',').skip(spaces())).skip(spaces())
    }
}

#[cfg(test)]
mod tests {
    use combine::stream::state::{State, SourcePosition};
    use combine::easy::Stream as EasyStream;
    use super::*;
    
    fn test<P>(mut p: P, input: &'static str)
    where
        P: Parser<Input=EasyStream<State<&'static str, SourcePosition>>>,
        P::Output: std::fmt::Debug,
    {
        println!("{:?}", p.easy_parse(State::new(input)).expect("success"))
    }
    
    #[test]
    fn expr_function_() {
        test(expr_function(), "x: y: PLACEHOLDER");
        test(expr_function(), "{ x, y ? PLACEHOLDER, ... }: PLACEHOLDER");
        test(expr_function(), "n@{ x, y ? PLACEHOLDER, ... }: PLACEHOLDER");
        test(expr_function(), "{ x, y ? PLACEHOLDER, ... }@n: PLACEHOLDER");
        test(expr_function(), "assert PLACEHOLDER; PLACEHOLDER");
        test(expr_function(), "let inherit w z; inherit (PLACEHOLDER) w z; in PLACEHOLDER");
    }

    #[test]
    fn expr_if_() {
        test(expr_if(), "if PLACEHOLDER then PLACEHOLDER else PLACEHOLDER");
    }
}
