package MT::Plugin::CommentRating;
use strict;
use warnings;
use MT::Plugin;
use base qw(MT::Plugin);

use vars qw($VERSION $SCHEMA_VERSION);
$VERSION = '0.2.0';
$SCHEMA_VERSION = '0.02';

use MT;
my $plugin = MT::Plugin::CommentRating->new({
    id => 'commentrating',
    key => __PACKAGE__,
    name => '5 Star Comment Rating',
    version => $VERSION,
    description => '<__trans phrase="Add five stars rating in the comments.">',
    author_name => 'Tomohiro Okuwaki',
    author_link => 'http://www.tinybeans.net/blog/',
    plugin_link => 'http://www.tinybeans.net/blog/download/mt-plugin/comment-rating.html',
    l10n_class => 'CommentRating::L10N',
    config_template => 'config.tmpl',
    settings => MT::PluginSettings->new([
        [ 'active', { Default => '', Scope => 'system' } ],
        [ 'active', { Default => '', Scope => 'blog' } ],
        [ 'decimal', { Default => '', Scope => 'system' } ],
        [ 'decimal', { Default => '', Scope => 'blog' } ],
        [ 'keys', { Default => '', Scope => 'system' } ],
        [ 'keys', { Default => '', Scope => 'blog' } ],
        [ 'once_rating', { Default => '', Scope => 'system' } ],
        [ 'once_rating', { Default => '', Scope => 'blog' } ],
    ]),
    schema_version => $SCHEMA_VERSION,
});
MT->add_plugin($plugin);

sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        callbacks => {
            'template_param.edit_comment' => '$commentrating::CommentRating::Plugin::cb_template_param_edit_comment',
            'MT::Comment::pre_save' => '$commentrating::CommentRating::Plugin::cb_comment_pre_save',
            'MT::Comment::post_save' => '$commentrating::CommentRating::Plugin::cb_comment_post_save',
            'cms_post_delete.comment' => '$commentrating::CommentRating::Plugin::cb_post_delete_comment',
        },
        object_types => {
            'comment' => { 'repetition' => 'integer' },
            'comment_rating' => 'CommentRating::Object',
        },
        tags => {
            function => {
                'CommentRating' => '$commentrating::CommentRating::Tag::handle_commentrating',
                'CommentRatingStar' => '$commentrating::CommentRating::Tag::handle_commentrating_star',
                'EntryRating' => '$commentrating::CommentRating::Tag::handle_entryrating',
                'EntryRatingStar' => '$commentrating::CommentRating::Tag::handle_entryrating_star',
                'EntryRatingCount' => '$commentrating::CommentRating::Tag::handle_entryrating_count',
            },
        },
    });
}

1;
