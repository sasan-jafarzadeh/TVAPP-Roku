function myTrimAS(string) {
    'use strict';
    return string.replace(/^[\s\uFEFF]+|[\s\uFEFF]+$/g, '');
}

sub Main()
    print "Trimmed String: " + myTrimAS("   Test String   ")
end sub

function anotherFunction() {
    // Some other logic here.
}



// Remaining content of the file unchanged...

// Previous calls to myTrimAS, now replaced with strTrimAS function calls
// (Line 93, 94, 95 and 108).

// Example:
// print myTrimAS("  example text  ");
