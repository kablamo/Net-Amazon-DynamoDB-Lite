use strict;
use Test::More 0.98;
use Time::Piece;
use Net::Amazon::DynamoDB::Lite;
use URI;

my $dynamo = Net::Amazon::DynamoDB::Lite->new(
    region     => 'ap-northeast-1',
    access_key => 'XXXXXXXXXXXXXXXXX',
    secret_key => 'YYYYYYYYYYYYYYYYY',
    uri => URI->new('http://localhost:8000'),
);

eval {
    $dynamo->list_tables;
};

my $t = localtime;
my $table = 'test_' . $t->epoch;
SKIP: {
    skip $@, 3 if $@;
    my $create_res = $dynamo->create_table($table, 5, 5, {id => 'HASH'}, {id => 'S'});
    ok $create_res;
    $dynamo->put_item($table, {id => "11111", last_update => "2015-03-30 18:41:23"});
    $dynamo->put_item($table, {id => "22222", last_update => "2015-03-30 18:41:23"});
    $dynamo->put_item($table, {id => "33333", last_update => "2015-03-30 18:41:23"});
    my $res = $dynamo->batch_get_item({$table => [{"id" => "22222"}]});
    is_deeply $res->[0]->{$table}, [
        {
            'last_update' => '2015-03-30 18:41:23',
            'id' => '22222'
        }
    ];
    $dynamo->delete_table($table);
}

done_testing;
