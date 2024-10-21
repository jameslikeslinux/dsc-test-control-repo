class profile::dsc {
  dsc_file { 'test':
    dsc_destinationpath => '/tmp/test.txt',
    dsc_contents        => "Hello, world!\n",
  }
}
