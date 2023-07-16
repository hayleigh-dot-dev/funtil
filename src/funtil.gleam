// TYPES -----------------------------------------------------------------------

/// This type is used to represent a value that can never happen. What does that
/// mean exactly?
/// 
/// - A `Bool` is a type that has two values: `True` and `False`.
/// - `Nil` is a type that has one value: `Nil`.
/// - `Never` is a type that has zero values: it's impossible to construct!
/// 
/// Why this type is useful is a bit of a mind-bender, but it's a useful tool to
/// have in your toolbox. For example, if you have a function that returns a
/// `Result(Int, Never)` then you *know* that it will always return an `Int` and
/// it is safe to use `let assert` to unwrap the value.
/// 
pub opaque type Never {
  JustOneMore(Never)
}

// MANIPULATIONS ---------------------------------------------------------------

/// If you've got a `Never` somewhere in a type it can be a bit of a problem if
/// you need something else. Just like [`Never`](#Never) is a type that can never
/// be constructed, `never` is a function that can never be called.
/// 
/// To take our `Result(Int, Never)` example from above, what if we want to
/// pass that value into a function that expects a `Result(Int, String)`? As it
/// stands, the types don't match up, but because we know that we can never have
/// an error, we can use `never` to pretend to convert it into a `String`:
/// 
/// ```gleam
/// import funtil.{Never, never}
/// import gleam/io
/// import gleam/result
/// 
/// fn log_error(result: Result(a, String)) -> Result(a, String) {
///   case result {
///     Ok(a) -> Nil
///     Error(message) -> io.println(message)
///   }
/// 
///   result
/// }
/// 
/// fn example() {
///   let val: Result(Int, Never) = Ok(42)
/// 
///   val
///   |> result.map_error(never)
///   |> log_error
/// }
/// ```
/// 
pub fn never(val: Never) -> a {
  case val {
    JustOneMore(x) -> never(x)
  }
}

// CONVERSIONS -----------------------------------------------------------------

/// Take any value and replace it with `Nil`. This can be a nicer way of using
/// value-producing functions in places where you only care about their side
/// effects.
///
pub fn void(_: a) -> Nil {
  Nil
}

// UTILS -----------------------------------------------------------------------

/// Gleam's type system does not support recursive `let`-bound functions, even
/// though they are theoretically possible. The `fix` combinator is a sneaky way
/// around this limitation by making the recursive function a parameter of
/// itself.
/// 
/// Sound a bit mind-bending? Let's first take a look at what happens if we try
/// to write a recursive `let`-bound function in Gleam:
/// 
/// ```gleam
/// pub fn example() {
///   let factorial = fn(x) {
///       case x {
///         0 -> 1
///         x -> x * factorial(x - 1)
///               // ^^^^^^^^^ The name `factorial` is not in scope here.
///       }
///     }
/// 
///   fact(5)
///   |> should.equal(120)
/// }
/// ```
/// 
/// We get a compile error because the name `factorial` is not in scope inside
/// the function body. What does it look like if we try to use `fix`?
/// 
/// /// ```gleam
/// import funtil.{fix}
/// 
/// pub fn example() {
///   let factorial =
///     fix(fn(factorial, x) {
///       case x {
///         0 -> 1
///         x -> x * factorial(x - 1)
///       }
///     })
/// 
///   fact(5)
///   |> should.equal(120)
/// }
/// ```
/// 
/// 🚨 Gleam is designed with this limitation to encourage you to pull things out
/// of `let` bindings when they get too complex. If you find yourself reaching for
/// `fix`, consider if there's a clearer way to solve your problem.
/// 
pub fn fix(f) {
  fn(x) { f(fix(f), x) }
}

/// A version of the [`fix`](#fix) util for functions that take two arguments.
/// 
/// /// 🚨 Gleam is designed with this limitation to encourage you to pull things out
/// of `let` bindings when they get too complex. If you find yourself reaching for
/// `fix2`, consider if there's a clearer way to solve your problem.
/// 
pub fn fix2(f) {
  fn(x, y) { f(fix2(f), x, y) }
}

/// A version of the [`fix`](#fix) util for functions that take three arguments.
/// 
/// /// 🚨 Gleam is designed with this limitation to encourage you to pull things out
/// of `let` bindings when they get too complex. If you find yourself reaching for
/// `fix3`, consider if there's a clearer way to solve your problem.
/// 
pub fn fix3(f) {
  fn(x, y, z) { f(fix3(f), x, y, z) }
}
