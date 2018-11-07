$().ready ->
  init()

  $('#modal_close').on('click', window.view)

view = ->
  $('.button, .card').remove()
  # 問題の描画
  if window.Question is null
    $('#question').html ''
  else
    $('#question').html window.Question.title

  # ボードの描画
  for index in [0...window.Board.length]
    card = window.Board[index]
    b = getElementButton(index)
    c = getElementBoard(card)
    $('#board').append b
    $('#board').append c
  # 最後のボタン
  b = getElementButton(window.Board.length)
  $('#board').append b

check = (index)->
  # 前のカード
  beforeCard = 
    if index is 0
      null
    else
      window.Board[index-1]
  # 問題のカード
  nowCard = window.Question
  # 次のカード
  afterCard = 
    if index is window.Board.length
      null
    else
      window.Board[index]

  # 正解であるかどうか
  isCorrect = true
  # 前のチェック
  isCorrect = false if beforeCard isnt null and nowCard.happened < beforeCard.happened
  # 後ろのチェック
  isCorrect = false if afterCard isnt null and afterCard.happened < nowCard.happened

  # 正解かどうか
  if isCorrect
    $('#modal-title').html('正解！')
  else
    $('#modal-title').html('間違い！')

  # 前
  $('#modal-before').html('')
  if beforeCard isnt null
    $('#modal-before').append(
      getElementModalBoard(beforeCard)
    )
  # 後ろ
  $('#modal-after').html('')
  if afterCard isnt null
    $('#modal-after').append(
      getElementModalBoard(afterCard)
    )
  # 今
  $('#modal-now').html('')
  $('#modal-now').append(getElementModalQuestion(nowCard))

  $('#modal_answer').modal('show')

  # 正解なら序列に入れる
  if isCorrect
    window.Board.splice(index, 0, nowCard)

  # 次の問題をセットする
  window.Question = window.CurrentCards.pop()

getElementBoard = (card)->
  $('<div>').addClass('card').append(
    $('<p>').html(card.title)
  )
getElementModalBoard = (card)->
  $('<div>').addClass('card').append(
    $('<p>').html(card.title)
  ).append(
    $('<p>').html(window.happened2date(card.happened))
  )
getElementModalQuestion = (card)->
  $('<div>').addClass('card_question').append(
    $('<p>').html(card.title)
  ).append(
    $('<p>').html(window.happened2date(card.happened))
  ).append(
    $('<p>').html(card.flavorText)
  )
getElementButton = (num)->
  $('<button>').addClass('btn btn-primary button').html('ここだ！').attr('data-order', num).on('click', ->
    window.check(Number $(@).attr('data-order'))
  )

happened2date = (happened)->
  ''+happened.toString().substr(0, 4)+'年'+happened.toString().substr(4, 2)+'月'+happened.toString().substr(6, 2)+'日'

init = (happenedStart = null, happenedEnd = null, tags = [])->
  window.Board = []
  window.Question = null
  window.CurrentCards = Utl.clone window.Cards

  # タグによる絞り込み
  if tags.length > 0
    taggedCards = []
    for tag in tags
      for card in window.CurrentCards
        for cardTag in card.tags
          if cardTag is tag
            taggedCards.push card
            break
    window.CurrentCards = taggedCards
  # 起こった日時による絞り込み
  if happenedStart isnt null and happenedEnd isnt null
    happenedCards = []
    for card in window.CurrentCards
      if happenedStart <= happened <= happenedEnd
        happenedCards.push card
        break
    window.CurrentCards = happenedCards

  # 最初はランダムに2つ置く
  window.CurrentCards = Utl.shuffle window.CurrentCards
  for index in [0...2]
    window.Board.push window.CurrentCards.pop()

  # 問題を設定
  window.Question = window.CurrentCards.pop()

  view()
