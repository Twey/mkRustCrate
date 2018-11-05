#![recursion_limit="512"]

extern crate derive_more;
extern crate combine;

pub mod token;
pub mod expr;
pub mod parse;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
