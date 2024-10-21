# An example profile
class profile::example (
  String $message = 'Hello, world!',
) {
  notify { $message: }
}
