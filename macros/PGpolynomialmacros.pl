
##########################################################
##  This file is PGpolynomialmacros.pl                  ##
##  It contains rountines used to create and manipulate ##
##  polynomials for WeBWorK                             ##
##                                                      ##
##  Copyright 2002 Mark Schmitt                         ##
##  Version 1.1.2                                       ##
##########################################################

##  In the current version, there is no attempt to verify that correct arrays are being passed to the routines.
##  This ought to be changed in the next incarnation.
##  It is assumed that arrays passed to the routines have no leading zeros, and represent the coefficients of
##  a polynomial written in standard form using place-holding zeros.
##  This means $array[0] is the leading coefficient of the polynomial and $array[$#array] is the constant term.
##
##  The routines were written based on the needs of my Honors Algebra 2 course.  The following algorithms have been
##  coded:
##      Polynomial Multiplication
##      Polynomial Long Division
##      Polynomial Synthetic Division (mainly as a support routine for checking bounds on roots)
##      Finding the least positive integral upper bounds for roots
##      Finding the greatest negative integral lower bounds for roots
##      Descartes' Rule of Signs for the maximum number of positive and negative roots
##      Stringification : converting an array of coefficients into a properly formatted polynomial string
##      Polynomial Addition
##      Polynomial Subtraction


##
## ValidPoly
##
sub ValidPoly {
    my $xref = @_;
    if (${$xref}[0] != 0) {return 1;}
    else {return 0;}
}

sub PolyAdd{
    my ($xref,$yref) = @_;
    @local_x = @{$xref};
    @local_y = @{$yref};
    if ($#local_x < $#local_y) {
    while ($#local_x < $#local_y) {unshift @local_x, 0;}
    }
    elsif ($#local_y < $#local_x) {
    while ($#local_y < $#local_x) {unshift @local_y, 0;}
    }
    foreach $i (0..$#local_x) {
        $sum[$i] = $local_x[$i] + $local_y[$i];
    }
    return @sum;
}

sub PolySub{
    my ($xref,$yref) = @_;
    @local_x = @{$xref};
    @local_y = @{$yref};
    if ($#local_x < $#local_y) {
        while ($#local_x < $#local_y) {unshift @local_x, 0;}
    }
    elsif ($#local_y < $#local_x) {
    while ($#local_y < $#local_x) {unshift @local_y, 0;}
    }
    foreach $i (0..$#local_x) {
        $diff[$i] = $local_x[$i] - $local_y[$i];
    }
    return @diff;
}

##
## @newPoly = PolyMult(~~@coefficientArray1,~~@coefficientArray2);
##
## accepts two arrays containing coefficients in descending order
## returns an array with the coefficients of the product
##

sub PolyMult{
    my ($xref,$yref) = @_;
    @local_x = @{$xref};
    @local_y = @{$yref};
    foreach $i (0..$#local_x + $#local_y) {$result[$i] = 0;}
    foreach $i (0..$#local_x) {
        foreach $j (0..$#local_y) {
           $result[$i+$j] = $result[$i+$j]+$local_x[$i]*$local_y[$j];
        }
    }
    return @result;
}

##
## (@quotient,$remainder) = SynDiv(~~@dividend,~~@divisor);
##

sub SynDiv{
    my ($dividendref,$divisorref)=@_;
    my @dividend = @{$dividendref};
    my @divisor = @{$divisorref};
    my @quotient;
    $quotient[0] = $dividend[0];
    foreach $i (1..$#dividend) {
        $quotient[$i] = $dividend[$i]-$quotient[$i-1]*$divisor[1];
    }
    return @quotient;
}

##
##
##
##
##

sub LongDiv{
    my ($dividendref,$divisorref)=@_;
    my @dividend = @{$dividendref};
    my @divisor = @{$divisorref};
    my @quotient; my @remainder;
    foreach $i (0..$#dividend-$#divisor) {
      $quotient[$i] = $dividend[$i]/$divisor[0];
      foreach $j (1..$#divisor) {
        $dividend[$i+$j] = $dividend[$i+$j] - $quotient[$i]*$divisor[$j];
      }
    }
    foreach $i ($#dividend-$#divisor+1..$#dividend) {
        $remainder[$i-($#dividend-$#divisor+1)] = $dividend[$i];
    }
    return (\@quotient,\@remainder);
}



##
## $upperBound = UpBound(~~@polynomial);
##
## accepts a reference to an array containing the coefficients, in descending
##   order, of a polynomial.
##
## returns the lowest positive integral upper bound to the roots of the
##   polynomial
##

sub UpBound {
    my $polyref=$_[0];
    my @poly = @{$polyref};
    my $bound = 0;
    my $test = 0;
    while ($test < @poly) {
        $bound++;
        $test=0;
        @div = (1,-$bound);
        @result = &SynDiv(\@poly,\@div);
        foreach $i (0..$#result) {
           if (sgn($result[$i])==sgn($result[0]) || $result[$i]==0) {
                $test++;
           }
        }
    }
    return $bound;
}


##
## $lowerBound = LowBound(~~@polynomial);
##
## accepts a reference to an array containing the coefficients, in descending
##   order, of a polynomial.
##
## returns the greatest negative integral lower bound to the roots of the
##   polynomial
##

sub LowBound {
    my $polyref=$_[0];
    my @poly = @{$polyref};
    my $bound = 0;
    my $test = 0;
    while ($test == 0) {
        $test = 1; $bound = $bound-1;
        @div = (1,-$bound);
        @res = &SynDiv(\@poly,\@div);
        foreach $i (1..int(($#res -1)/2)) {
            if (sgn($res[0])*sgn($res[2*$i]) == -1) {
            $test = 0;}
        }
        foreach $i (1..int($#res/2)) {
            if (sgn($res[0])*sgn($res[2*$i-1]) == 1) {
            $test = 0;}
        }
    }
    return $bound;
}




##
## $string = PolyString(~~@coefficientArray,x);
##
## accepts an array containing the coefficients of a polynomial
##   in descending order
## returns a sting containing the polynomial with variable v
## default variable is x
##

sub PolyString{
	my $temp = $_[0];
	my @poly = @{$temp};
	my $string = '';
	foreach my $i (0..$#poly) {
		my $j = $#poly-$i;
		if ($j == $#poly) {
			if ($poly[$i] >0) {
				if ($poly[$i]!=1){
					$string = $string."$poly[$i] x^{$j}";
				}
				else {$string=$string."x^{$j}";}
			}
			elsif ($poly[$i] == 0) {}
			elsif ($poly[$i] == -1) {$string=$string."-x^{$j}";}
			else {$string = $string."$poly[$i] x^{$j}";}	
		}
		elsif ($j > 0 && $j!=1) {
			if ($poly[$i] >0) {
				if ($poly[$i]!=1){
					$string = $string."+$poly[$i] x^{$j}";
				}
				else {$string = $string."+x^{$j}";}}
			elsif ($poly[$i] == 0) {}
			elsif ($poly[$i] == -1) {$string=$string."-x^{$j}";}
			else {$string = $string."$poly[$i] x^{$j}";}
		}
		elsif ($j == 1) {
			if ($poly[$i] > 0){
		  		if ($poly[$i]!=1){
					$string = $string."+$poly[$i] x";
				}
		  		else {$string = $string."+x";}
		  	}
			elsif ($poly[$i] == 0) {}
			elsif ($poly[$i] == -1){$string=$string."-x";}
			else {$string=$string."$poly[$i] x";}
		}
		else {
			if ($poly[$i] > 0){
		  		$string = $string."+$poly[$i] ";
		  	}
			elsif ($poly[$i] == 0) {}
			else {$string=$string."$poly[$i] ";}
		}
	}
	return $string;
}


sub PolyFunc {
    my $temp = $_[0];
    my @poly = @{$temp};
    $func = "";
    foreach $i (0..$#poly) {
        $j = $#poly-$i;
        if ($poly[$i] > 0) {$func = $func."+$poly[$i]*x**($j)";}
        else {$func = $func."$poly[$i]*x**($j)";}
    }
    return $func;
}

##
## ($maxpos,$maxneg) = Descartes(~~@poly);
##
## accepts an array containing the coefficients, in descending order, of a
##  polynomial
## returns the maximum number of positive and negative roots according to
##  Descartes Rule of Signs
##
## IMPORTANT NOTE:  this function currently does not accept coefficients of
##  zero.
##

sub Descartes {
    my $temp = $_[0];
    my @poly = @{$temp};
    my $pos = 0; my $neg = 0;
    foreach $i (1..$#poly) {
        if (sgn($poly[$i])*sgn($poly[$i-1]) == -1) {$pos++;}
        elsif (sgn($poly[$i])*sgn($poly[$i-1]) == 1) {$neg++;}
    }
    return ($pos,$neg);
}










1;
