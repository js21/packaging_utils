package Sanger::Debian::CommandLine::UsageToMan;

#Abstract: Convert the usage blurbs from any code that is being packaged into Unix man pages

use Getopt::Long qw(GetOptionsFromArray);


sub new {

  my $class = shift;
  
  my $self = {
	      args => shift,
	      script_name => shift
	     };

  bless $self, $class;

  #print Dumper($self->_args);
  # my ($package_name, $help);
  # GetOptionsFromArray(
  # 		      %args,
  # 		      'p|package_name=s' => \$package_name,
  # 		      'h|help' => \$help
  # 		     );
  # $self->package_name($package_name) if ( defined($package_name) );
  
  return $self;
}


sub run {

  my ($self) = @_;
  use Data::Dumper;
  print Dumper($self->args);

}

1;
