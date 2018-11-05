use combine::stream::Stream;
use combine::*;

use crate::token::Token;
use crate::expr::*;

parser! {
    pub fn list[I]()(I) -> List
    where [
        I: Stream<Item=Token>,
    ] {
        between(token(Token::OpenSquare),
                token(Token::CloseSquare),
                many(expr()))
    }
}

parser! {
    pub fn id[I]()(I) -> Id
    where [
        I: Stream<Item=Token>,
    ] {
        satisfy_map(|x| if let Token::Id(x) = x { Some(x) } else { None })
    }
}

parser! {
    pub fn binding[I]()(I) -> Binding
    where [
        I: Stream<Item=Token>,
    ] {
        choice! {
            token(Token::Inherit).then(|_| {
                between(token(Token::OpenRound),
                        token(Token::CloseRound),
                        expr())
                    .then(|e| many(id()).map(
                        move |ids| Binding::InheritFrom(
                            Box::new(e.clone()), ids)))
            })
        }
    }
}

parser! {
    pub fn bindings[I]()(I) -> Vec<Binding>
    where [
        I: Stream<Item=Token>,
    ] {
        sep_end_by(binding(), token(Token::Semicolon))
    }
}

parser! {
    pub fn attr_set[I]()(I) -> AttrSet
    where [
        I: Stream<Item=Token>,
    ] {
        optional(token(Token::Rec))
            .map(|x| x.is_some())
            .then(|recursive| {
                between(
                    token(Token::OpenCurly),
                    token(Token::CloseCurly),
                    bindings().map(
                        move |bindings| AttrSet { recursive, bindings }))
            })
    }
}

parser! {
    pub fn int[I]()(I) -> u64
    where [
        I: Stream<Item=Token>,
    ] {
        satisfy_map(|x| if let Token::Int(x) = x { Some(x) } else { None })
    }
}

parser! {
    pub fn float_[I]()(I) -> String
    where [
        I: Stream<Item=Token>,
    ] {
        satisfy_map(|x| if let Token::Float(x) = x { Some(x) } else { None })
    }
}


parser! {
    pub fn string[I]()(I) -> String
    where [
        I: Stream<Item=Token>,
    ] {
        value(unimplemented!())
        // between(token(Token::Quote), token(Token::Quote), satisfy_map(|x| if let Token::Str(s) = x { Some(s) } else { None }))
    }
}

parser! {
    pub fn ind_string[I]()(I) -> String
    where [
        I: Stream<Item=Token>,
    ] {
        value(unimplemented!())
    }
}

parser! {
    pub fn literal[I]()(I) -> Literal
    where [
        I: Stream<Item=Token>,
    ] {
        choice! {
            list().map(Literal::List),
            attr_set().map(Literal::AttrSet),
            int().map(Literal::Int),
            float_().map(Literal::Float),
            string().map(Literal::String),
            attempt(ind_string()).map(Literal::IndString)
            // attempt(var()),
            // attempt(path()),
            // attempt(uri())
        }
    }
}

parser! {
    pub fn expr[I]()(I) -> Expr
    where [
        I: Stream<Item=Token>,
    ] {
        choice! {
            attempt(literal()).map(Expr::Literal)
        }
            /*
        choice! {
            attempt(bound()),
            attempt(conditional()),
            attempt(operation()),
            attempt(application()),
            attempt(selection()),
            attempt(literal())
        }
         */
    }
}
