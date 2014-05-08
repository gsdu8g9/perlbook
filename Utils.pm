package Utils;

use nginx;

sub restart {
    my $r = shift;
    
    $r->send_http_header("text/html");  
    my $res = `/home/perlito/perlbook/pull.sh`;
    
    $r->print($res);

    return OK;
}

1;