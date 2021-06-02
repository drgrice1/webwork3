package DB::Schema::ResultSet::Course;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Carp;
use Data::Dump qw/dd/;
use List::Util qw/first/;

use DB::Utils qw/parseCourseInfo/;


=pod
 
=head1 DESCRIPTION
 
This is the functionality of a Course in WeBWorK.  This package is based on 
<code>DBIx::Class::ResultSet</code>.  The basics are a CRUD for anything on the 
global courses.  
 
=cut

=pod
=head2 getCourses

This gets a list of Courses stored in the database in the <code>courses</codes> table. 

=head3 input 

<code>$as_result_set</code>, a boolean if the return is to be a result_set

=head3 output 

An array of courses as a <code>DBIx::Class::ResultSet::Course</code> object
if <code>$as_result_set</code> is true.  Otherwise an array of hash_ref.  

=cut

sub getCourses {
	my ($self, $as_result_set)  = @_; 
	my @courses = $self->search();
	return @courses if $as_result_set; 
	return map { {$_->get_columns}; } @courses; 
} 

=pod
=head1 getCourse

This gets a single course that is stored in the database in the <code>courses</codes> table. 

=head3 input 
=item *
<code>course_info</code>, a hashref containing either course_name or course_id
=item *
<code>result_set</code>, a a boolean if the return is to be a result_set

=head3 output 

The course either as a <code> DBIx::Class::ResultSet::Course</code> object or a hashref 
of the fields.  

=cut

sub getCourse {
	my ($self,$course_info,$as_result_set) = @_;
  parseCourseInfo($course_info);
	my $course = $self->find($course_info);
	die "The course with $course_info is not defined" unless $course; 
	return $course if $as_result_set; 
	return {$course->get_columns}; 
}

=pod
=head1 addCourse

Adds a single course to the database in the <code>courses</codes> table. 

=head3 input 

A set of parameters, especially a <code>course_name</code> of type string. 

=head3 output 

The added course as a <code>DBIx::Class::ResultSet::Course</code> object.  

=cut

sub addCourse {
	my ($self,$course_name,$as_result_set) = @_;
	## check if the course exists.  If so throw an error. 
	my $course = $self->find({course_name => $course_name}); 
	die "The course with name $course_name already exists." if defined($course); 

	my $new_course = $self->create({course_name => $course_name});
	return $new_course if $as_result_set; 
	return {$new_course->get_columns};
}

=pod
=head1 deleteCourse

This deletes a single course that is stored in the database in the <code>courses</codes> table. 

=head3 input 

<code>course_name</code>, a string, the name of the course to be deleted.  

=head3 output 

The deleted course as a <code>DBIx::Class::ResultSet::Course</code> object.  

=cut


## TODO: delete everything related to the course from all tables. 

sub deleteCourse {
	my ($self,$course_info) = @_;
	parseCourseInfo($course_info);
	my $course_to_delete = $self->getCourse($course_info,1);

	my $deleted_course = $course_to_delete->delete;
	return {$deleted_course->get_columns};
}

=pod
=head1 updateCourse

This updates a single course that is stored in the database in the <code>courses</codes> table. 

=head3 input 

=item * 
<code>course_name</code>, a string
=item *
A hash of the course parameters to be updated.  

=head3 output 

The updated course as a <code>DBIx::Class::ResultSet::Course</code> object.  

=cut

sub updateCourse {
	my ($self,$course_info,$course_params,$as_result_set) = @_;
	parseCourseInfo($course_info);
	my $course = $self->getCourse($course_info,1);
	$course->update($course_params);
	return $course if $as_result_set; 
	return {$course->get_columns}; 
}




1;