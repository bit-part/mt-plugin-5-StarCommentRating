package CommentRating::L10N::ja;
use strict;
use warnings;
use base qw(CommentRating::L10N::en_us);
use vars qw( %Lexicon );

%Lexicon = (
# CommentRating.pl
    'Add five stars rating in the comments.' => 'コメント欄に格付けを追加します。',
# config.tmpl
    'active' => '有効にする',
    'IP check' => 'IPチェック',
    'decimal' => '端数',
    'display the first decimal place' => '小数第一位まで表示する',
    'Not save repetition ip' => 'IPアドレスが重複する場合は評価を保存しない。',
    'keys(separate space)' => 'キー（半角スペース区切り）',
# CMS.pm
    'Rating' => '評価',
    'It is the value that evaluated a entry with five phases.' => 'ブログ記事を５段階で評価した値です。',
);

1;

