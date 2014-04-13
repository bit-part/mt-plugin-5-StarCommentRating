package CommentRating::Plugin;
use strict;
use warnings;
use MT;
use MT::Comment;
use CommentRating::Object;

sub get_configs {
    my ($ctx_blog) = @_;
    my $blog_id = ref($ctx_blog) ? $ctx_blog->id : $ctx_blog;
    my $plugin = MT->component('commentrating');
    my $configs = {blog=>{},sys=>{}};
    $plugin->load_config($configs->{blog},'blog:' . $blog_id);
    $plugin->load_config($configs->{sys},'system');
    return $configs;
}

sub select_config {
    my ($configs,$key) = @_;
    if( defined($configs->{blog}{$key}) && $configs->{blog}{$key} ne '' ) {
        return $configs->{blog}{$key};
    }
    if( defined($configs->{sys}{$key}) ) {
        return $configs->{sys}{$key};
    }
    return '';
}

sub cb_comment_pre_save {
    my ($cb, $obj, $original) = @_;
    
    my $comment_id = $obj->id;
    my $blog_id = $obj->blog_id;
    my $entry_id = $obj->entry_id;
    my $ip = $obj->ip;
    
    my $conf = get_configs($blog_id);
    my $active = select_config($conf, 'active');
    return unless $active;
    my $once_rating = select_config($conf, 'once_rating');
    
    my $app = MT->instance();

    # Check IP address
    $obj->repetition(1);
    my @ratings = CommentRating::Object->load({ entry_id => $entry_id });
    for my $rating (@ratings) {
        if ($ip eq $rating->ip) {
            $obj->repetition(0);
            $app->log('IP adress repetition');
            last;
        }
    }
    
    return $obj;
}

sub save_comment_rating {
    my ($blog_id, $entry_id, $comment_id, $ip, $key, $value, $repetition) = @_;
    
    my $obj = CommentRating::Object->new;
    $obj->blog_id($blog_id);
    $obj->entry_id($entry_id);
    $obj->comment_id($comment_id);
    $obj->ip($ip);
    $obj->key($key);
    $obj->value($value);
    $obj->repetition($repetition);
    $obj->save or die 'Can not saved.';
}

sub cb_comment_post_save {
    my ($cb, $obj, $original) = @_;
    
    my $app = MT->instance();

    # Get value
    my $comment_id = $obj->id;
    my $blog_id = $obj->blog_id;
    my $entry_id = $obj->entry_id;
    my $ip = $obj->ip;
    my $repetition = $obj->repetition;

    # Check active
    my $conf = get_configs($blog_id);
    my $active = select_config($conf, 'active');
    return unless $active;
    my $once_rating = select_config($conf, 'once_rating');
   
    unless ( ($once_rating == 1) && ($repetition == 0) ) {
        my $keys = select_config($conf, 'keys');
        my @keys = split /\s+/, $keys;    
    
        for my $key (@keys) {
            my $value = $app->param($key);
            &save_comment_rating($blog_id, $entry_id, $comment_id, $ip, $key, $value, $repetition) if $value;
        }
    }
}

sub cb_post_delete_comment {
    my ($cb, $app, $obj) = @_;
    my $comment_id = $obj->id;
    CommentRating::Object->remove({ comment_id => $comment_id });
}

sub cb_template_param_edit_comment {
    my ($cb, $app, $param, $tmpl) = @_;
    return unless UNIVERSAL::isa($tmpl, 'MT::Template');

    my $blog_id = $param->{'blog_id'};
    my $comment_id = $param->{'id'};
    my $conf = get_configs($blog_id);
    my $keys = select_config($conf, 'keys');
    return unless $keys;

    my $innerHTML;
    my @keys = split /\s+/, $keys;    
    for my $key (@keys) {
        my $value;
        my @ratings = CommentRating::Object->load({ comment_id => $comment_id, key => $key });
        for my $rating (@ratings) {
            $value = $rating->value;
        }
        $innerHTML .= $key . ' : ' . $value . ', ';
    }
    $innerHTML =~ s/(,\s)$//;
    my $pointer_field = $tmpl->getElementById('ip');
    my $label = '<__trans_section component="commentrating"><__trans phrase="Rating"></__trans_section>';
    my $hint = '<__trans_section component="commentrating"><__trans phrase="It is the value that evaluated a entry with five phases."></__trans_section>';
    my $nodeset = $tmpl->createElement('app:setting', { id => 'rating', label => $label, hint => $hint, show_hint => 0 });
    $nodeset->innerHTML($innerHTML);
    $tmpl->insertAfter($nodeset, $pointer_field);    
}

1;
