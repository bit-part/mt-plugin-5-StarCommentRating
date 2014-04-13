package CommentRating::Object;
use strict;
use warnings;
use base qw(MT::Object);
use MT::Comment;

__PACKAGE__->install_properties({
    column_defs => {
        'id' => 'integer not null auto_increment',
        'blog_id' => 'integer not null',
        'entry_id' => 'integer not null',
        'comment_id' => 'integer not null',
        'ip' => 'string(50)',
        'key' => 'string(255)',
        'value' => 'integer',
        'repetition' => 'integer',
    },
    indexes => {
        entry_id => 1,
        comment_id => 1,
        ip => 1,
    },
    child_of => 'MT::Comment',
    datasource => 'comment_rating',
    primary_key => 'id',
    audit => 1,
});

1;
