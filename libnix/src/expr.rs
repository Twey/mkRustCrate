pub type Id = String;

#[derive(Clone, Debug)]
pub struct NonEmptyVec<T> {
    pub head: T,
    pub tail: Vec<T>,
}

#[derive(Clone, Debug)]
pub enum Expr {
    Bound(Bound),
    Conditional(Conditional),
    Operation(Operation),
    Application(Application),
    Selection(Selection),
    Literal(Literal),
}

#[derive(Clone, Debug)]
pub enum Parameter {
    Ellipsis,
    Named {
        name: Id,
        default: Option<Box<Expr>>,
    },
}

#[derive(Clone, Debug)]
pub enum Pattern {
    Name(String),
    Set {
        name: Option<String>,
        parameters: Vec<Parameter>,
    },
}

#[derive(Clone, Debug)]
pub enum AttrName {
    Literal(Id),
    Dynamic(Box<Expr>),
}

pub type AttrPath = NonEmptyVec<AttrName>;

#[derive(Clone, Debug)]
pub enum Binding {
    Inherit {
        source: Option<Box<Expr>>,
        attrs: Vec<Id>, // TODO this is oversimplified
    },
    Attr(AttrPath),
}

pub type Bindings = Vec<Binding>;

#[derive(Clone, Debug)]
pub enum Binder {
    Function(Pattern),
    Assert(Box<Expr>),
    With(Box<Expr>),
    Let(Bindings),
}

#[derive(Clone, Debug)]
pub struct Bound {
    pub binder: Binder,
    pub body: Box<Expr>,
}    

#[derive(Clone, Debug)]
pub struct Conditional {
    pub cond: Box<Expr>,
    pub then_: Box<Expr>,
    pub else_: Box<Expr>,
}

#[derive(Clone, Debug)]
pub enum UnaryOperator { Not, Negate }
#[derive(Clone, Debug)]
pub enum BinaryOperator {
    Eq, Neq, Lt, Gt, Geq, Leq,
    And, Or, Impl,
    Update,
    Plus, Minus, Multiply, Divide,
    Concat,
}
#[derive(Clone, Debug)]
pub enum AttrOperator { Question, OrKw }

#[derive(Clone, Debug)]
pub enum Operation {
    Unary {
        op: UnaryOperator,
        arg: Box<Expr>,
    },
    Binary {
        op: BinaryOperator,
        lhs: Box<Expr>,
        rhs: Box<Expr>,
    },
    Attr {
        op: AttrOperator,
        lhs: Box<Expr>,
        rhs: AttrPath,
    },
}

#[derive(Clone, Debug)]
pub struct Application {
    pub function: Box<Expr>,
    pub argument: Box<Expr>,
}

#[derive(Clone, Debug)]
pub struct Selection {
    pub base: Box<Expr>,
    pub path: AttrPath,
    pub default: Option<Box<Expr>>,
}

#[derive(Clone, Debug)]
pub struct StringPart {
    pub dynamic: Box<Expr>,
    pub literal: String,
}

#[derive(Clone, Debug)]
pub struct StringParts {
    pub head: String,
    pub tail: Vec<StringPart>,
}

#[derive(Clone, Debug)]
pub enum Path {
    Angle(String),
    Normal(String),
}

pub type List = Vec<Expr>;

#[derive(Clone, Debug)]
pub struct AttrSet {
    pub recursive: bool,
    pub bindings: Bindings,
}

#[derive(Clone, Debug)]
pub enum Literal {
    Var(Id),
    Int(u64),
    Float(String), // no Eq
    String(String),
    IndString(String),
    Path(Path),
    Uri(String),
    AttrSet(AttrSet),
    List(List),
}
