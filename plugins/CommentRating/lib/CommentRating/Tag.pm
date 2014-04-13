package CommentRating::Tag;
use strict;
use warnings;
use MT;
use MT::Comment;
use CommentRating::Object;
use CommentRating::Plugin;

# <mt:FunctionTag key="foo" /> : fooはプラグインの設定keysで指定した値のいずれか

sub handle_commentrating {
    my ( $ctx, $args ) = @_;

    my $comment = $ctx->stash('comment')
        or return $ctx->_no_comment_error();

    my $blog = $ctx->stash('blog');
    my $conf = &CommentRating::Plugin::get_configs($blog->id);
    my $decimal = &CommentRating::Plugin::select_config($conf, 'decimal');

    my $comment_id = $comment->id;
    my $key = $args->{key};
    my ($value, @ratings, $result);
    if ($key) {
        @ratings = CommentRating::Object->load({ comment_id => $comment_id, key => $key });
        for my $rating (@ratings) { $value += $rating->value; }
        return $value || 0;
    } else {
        @ratings = CommentRating::Object->load({ comment_id => $comment_id });
        for my $rating (@ratings) { $value += $rating->value; }
        if ($value) {
            if ($decimal) {
                $result = (int(($value / @ratings) * 10 + 0.5)) / 10;
            } else {
                $result = int($value / @ratings + 0.5);
            }
        }
        return $result || 0;
    }
}

sub handle_commentrating_star {
    my ( $ctx, $args ) = @_;
    my $value = &handle_commentrating( $ctx, $args ) || 0;
    return '<span class="rating star_'.int($value).'" title="'.$value.' stars"><span>'.$value.' stars</span></span>';
}

sub handle_entryrating {
    my ( $ctx, $args ) = @_;

    my $entry = $ctx->stash('entry')
        or return $ctx->_no_entry_error();

    my $blog = $ctx->stash('blog');
    my $conf = &CommentRating::Plugin::get_configs($blog->id);
    my $decimal = &CommentRating::Plugin::select_config($conf, 'decimal');

    my $entry_id = $entry->id;
    my $key = $args->{key};
    my ($value, @ratings, $result);
    if ($key) {
        @ratings = CommentRating::Object->load({ entry_id => $entry_id, key => $key });

    } else {
        @ratings = CommentRating::Object->load({ entry_id => $entry_id });
    }
    for my $rating (@ratings) { $value += $rating->value; }
    if ($value) {
        if ($decimal) {
            $result = (int(($value / @ratings) * 10 + 0.5)) / 10;
        } else {
            $result = int($value / @ratings + 0.5);
        }
    }
    return $result || 0;
}

sub handle_entryrating_star {
    my ( $ctx, $args ) = @_;
    my $value = &handle_entryrating( $ctx, $args ) || 0;
    return '<span class="rating star_'.int($value).'" title="'.$value.' stars"><span>'.$value.' stars</span></span>';
}

sub handle_entryrating_count {
    my ( $ctx, $args ) = @_;
    # my $app = MT->instance();

    my $entry = $ctx->stash('entry')
        or return $ctx->_no_entry_error();
    my $entry_id = $entry->id;
    my $key = $args->{key};
    
    my @ratings;
    if ($key) {
        @ratings = CommentRating::Object->load({ entry_id => $entry_id, key => $key });
    } else {
        @ratings = CommentRating::Object->load({ entry_id => $entry_id });
    }
    my $count = @ratings;
    return $count || 0;
}

1;
