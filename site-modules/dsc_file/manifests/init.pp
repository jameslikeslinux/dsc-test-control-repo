# @summary Legacy dsc_file compatibility wrapper
#
# Provide an identical interface to the legacy dsc_file resource type
# from the deprecated puppetlabs/dsc module by wrapping the more
# generic puppetlabs/dsc_lite module.
#
# @param dsc_destinationpath File name and path on target node to copy or create
# @param dsc_psdscrunascredential Run resource under this set of credentials
# @param dsc_ensure Defines how to evaluate the existence of the destination file
# @param dsc_type A choice between File and Directory. The default value is File.
# @param dsc_sourcepath The name and path of the file to copy from
# @param dsc_contents Contains a string that represents the contents of the file
# @param dsc_checksum The checksum type to use when determining whether two files are the same
# @param dsc_recurse Recurse all child directories
# @param dsc_force Perform the file operation even if it will destroy content files or directories
# @param dsc_credential Credential to access remote resources
# @param dsc_attributes Attributes for file/directory
# @param dsc_dependson List of other DSC resources on which this depends
# @param dsc_matchsource Always compare the DestinationPath with the SourcePath
# @param ensure Defaults to `dsc_ensure`
#
# @see https://github.com/puppetlabs-toy-chest/puppetlabs-dsc/blob/main/lib/puppet/type/dsc_file.rb
# @see https://forge.puppet.com/modules/puppetlabs/dsc_lite/readme
define dsc_file (
  String $dsc_destinationpath,
  Enum['Present', 'present', 'Absent', 'absent'] $dsc_ensure = 'Present',
  Optional[Hash[Enum['user', 'password'], Variant[Sensitive, String]]] $dsc_psdscrunascredential = undef,
  Optional[Enum['File', 'file', 'Directory', 'directory']] $dsc_type = undef,
  Optional[String] $dsc_sourcepath = undef,
  Optional[String] $dsc_contents = undef,
  Optional[Enum['SHA-1','sha-1','SHA-256','sha-256','SHA-512','sha-512','CreatedDate','createddate','ModifiedDate','modifieddate']] $dsc_checksum = undef,
  Optional[Boolean] $dsc_recurse = undef,
  Optional[Boolean] $dsc_force = undef,
  Optional[Hash[Enum['user', 'password'], Variant[Sensitive, String]]] $dsc_credential = undef,
  Optional[Array[Enum['ReadOnly','readonly','Hidden','hidden','System','system','Archive','archive']]] $dsc_attributes = undef,
  Optional[Array[String]] $dsc_dependson = undef,
  Optional[Boolean] $dsc_matchsource = undef,
  Enum['present', 'absent'] $ensure = $dsc_ensure.downcase,
) {
  if $dsc_psdscrunascredential and $dsc_psdscrunascredential['user'] and $dsc_psdscrunascredential['password'] {
    $user = $dsc_psdscrunascredential['user']
    $pass = $dsc_psdscrunascredential['password']

    $psdscrunascredential_props = {
      'dsc_type' => 'MSFT_Credential',
      'dsc_properties' => {
        'user'     => $user,
        'password' => $pass ? {
          Sensitive => $pass,
          default   => Sensitive($pass),
        },
      },
    }
  } else {
    $psdscrunascredential_props = undef
  }

  if $dsc_credential and $dsc_credential['user'] and $dsc_credential['password'] {
    $user = $dsc_credential['user']
    $pass = $dsc_credential['password']

    $credential_props = {
      'dsc_type' => 'MSFT_Credential',
      'dsc_properties' => {
        'user'     => $user,
        'password' => $pass ? {
          Sensitive => $pass,
          default   => Sensitive($pass),
        },
      },
    }
  } else {
    $credential_props = undef
  }

  $properties = {
    'DestinationPath'      => $dsc_destinationpath,
    'Ensure'               => $ensure,
    'PsDscRunAsCredential' => $psdscrunascredential_props,
    'Type'                 => $dsc_type,
    'SourcePath'           => $dsc_sourcepath,
    'Contents'             => $dsc_contents,
    'Checksum'             => $dsc_checksum,
    'Recurse'              => $dsc_recurse,
    'Force'                => $dsc_force,
    'Credential'           => $credential_props,
    'Attributes'           => $dsc_attributes,
    'DependsOn'            => $dsc_dependson,
    'MatchSource'          => $dsc_matchsource,
  }.delete_undef_values

  dsc { $name:
    resource_name => 'MSFT_FileDirectoryConfiguration',
    module        => 'PSDesiredStateConfiguration',
    properties    => $properties,
  }
}
