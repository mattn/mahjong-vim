scriptencoding utf-8

let s:hai = split('一二三四五六七八九', '\zs')

function! s:judge2(ctx)
  let ctx = a:ctx
  if len(ctx.mentu) == 12
    return 1
  endif
  for n in range(len(ctx.hai))
    if ctx.hai[n] >= 3
      call add(ctx.mentu, n)
      call add(ctx.mentu, n)
      call add(ctx.mentu, n)
      let ctx.hai[n] -= 3
      if s:judge2(ctx)
        return 1
      endif
    endif
  endfor
  for n in range(len(ctx.hai)-2)
    if ctx.hai[n] > 0 && ctx.hai[n+1] > 0 && ctx.hai[n+2] > 0
      call add(ctx.mentu, n+0)
      call add(ctx.mentu, n+1)
      call add(ctx.mentu, n+2)
      let ctx.hai[n+0] -= 1
      let ctx.hai[n+1] -= 1
      let ctx.hai[n+2] -= 1
      if s:judge2(ctx)
        return 1
      endif
    endif
  endfor
  return 0
endfunction

function! s:judge1(hai)
  let ctx = {"hai": a:hai, "mentu": [], "atama": -1}
  for n in range(len(a:hai))
    if a:hai[n] >= 2
      let ctx = {"hai": deepcopy(a:hai), "mentu": [], "atama": n}
      let ctx.hai[n] -= 2
      if s:judge2(ctx)
        break
      endif
      let ctx.atama = -1
    endif
  endfor
  return ctx
endfunction

function! s:judge(chai, c)
  let hai = [0,0,0,0,0,0,0,0,0]  
  for n in range(len(a:chai))
    let hai[str2nr(a:chai[n])] += 1
  endfor
  let ret = s:judge1(hai)
  if ret.atama == -1
    echohl WarningMsg | echomsg "CUOHUO!!" | echohl None
    return
  endif
  echohl Title | echomsg "YOU WIN IN ".(a:c).(a:c == 1 ? "ST TIME!!" : "TH TIMES!!") | echohl None
  echohl MahjongBlock
  if &ambiwidth == 'double' || has('win32') || has('win64')
    echo "┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐\n"
  else
    echo "┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐\n"
  endif
  for h in ret.mentu + [ret.atama, ret.atama]
    echohl MahjongBlock
    echon "│"
    echohl MahjongNumber
    echon s:hai[h]
  endfor
  echohl MahjongBlock
  echon "│\n"
  for h in repeat(["萬"], 14)
    echohl MahjongBlock
    echon "│"
    echohl MahjongUnit
    echon h
  endfor
  echohl MahjongBlock
  echon "│\n"
  if &ambiwidth == 'double' || has('win32') || has('win64')
    echo "└─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘"
  else
    echo "└──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘"
  endif
  echohl None
endfunction

let s:seed = 0
function! s:srand(seed)
  let s:seed = a:seed
endfunction

function! s:rand()
  let s:seed = s:seed * 214013 + 2531011
  return (s:seed < 0 ? s:seed - 0x80000000 : s:seed) / 0x10000 % 0x8000
endfunction

function! s:display(mountain, hai, tsumo, x)
  let o = ""
  for n in range(len(a:hai))
    let o .= "│".s:hai[a:hai[n]]
  endfor
  let o .= "││".s:hai[a:tsumo]."│"
  silent %d
  if &ambiwidth == 'double' || has('win32') || has('win64')
    call setline(1, "┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐┌─┐")
    call setline(2, o)
    call setline(3, "│萬│萬│萬│萬│萬│萬│萬│萬│萬│萬│萬│萬│萬││萬│")
    call setline(4, "└─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘└─┘")
    call setline(5, repeat(' ', a:x * 4 + (a:x == 13 ? 4 : 2)).'＾')
  else
    call setline(1, "┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐┌──┐")
    call setline(2, o)
    call setline(3, "│萬│萬│萬│萬│萬│萬│萬│萬│萬│萬│萬│萬│萬││萬│")
    call setline(4, "└──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘└──┘")
    call setline(5, repeat(' ', a:x * 3 + (a:x == 13 ? 2 : 1)).'＾')
  endif
  call setline(6, " h/l: move, <space>: discard, <enter>/x: judge, <esc>/q: quit")
endfunction

function! s:tsumo(mountain)
  let rest = 0
  for n in a:mountain
    let rest += n
  endfor
  if rest == 0
    return -1
  endif
  while 1
    let n = s:rand()%9
    if a:mountain[n] > 0
      let a:mountain[n] -= 1
      return n
    endif
  endwhile
endfunction

function! s:mahjong()
  let winnum = bufwinnr(bufnr('==MAHJONG=='))
  if winnum != -1
    if winnum != bufwinnr('%')
      exe "normal \<c-w>".winnum."w"
    endif
  else
    silent 6split `='==MAHJONG=='`
  endif
  setlocal modifiable
  setlocal buftype=nowrite
  setlocal noswapfile
  setlocal bufhidden=wipe
  setlocal buftype=nofile
  setlocal nonumber
  setlocal nolist
  setlocal nowrap
  setlocal nocursorline
  setlocal nocursorcolumn
  normal gg0
  syn match MahjongBlock /[┌─┬┐│└┴┘]/
  syn match MahjongUnit '萬'
  syn match MahjongNumber /[一二三四五六七八九]/
  hi MahjongBlock ctermfg=green ctermbg=NONE guifg=green guibg=NONE
  hi MahjongUnit ctermfg=red ctermbg=NONE guifg=red guibg=NONE
  hi MahjongNumber ctermfg=white ctermbg=NONE guifg=white guibg=NONE

  call s:srand(localtime())
  let mountain = [4,4,4,4,4,4,4,4,4]
  let hai = []
  for _ in range(13)
    call add(hai, s:tsumo(mountain))
  endfor
  let hai = sort(hai)
  let x = 13
  let r = 1
  let t = s:tsumo(mountain)
  while 1
    call s:display(mountain, hai, t, x)
    redraw
    let c = nr2char(getchar())
    if c == 'q' || c == "\x1b"
      bdelete
      break
    elseif c == 'h'
      if x > 0
        let x -= 1
      endif
      call setpos('.', [0, 1, x * 4 + 3, 0])
    elseif c == 'l'
      if x < 13
        let x += 1
      endif
      call setpos('.', [0, 1, x * 4 + 3, 0])
    elseif c == ' '
      if x < 13
        call remove(hai, x)
        call add(hai, t)
        let hai = sort(hai)
      endif 
      let t = s:tsumo(mountain)
      if t == -1
        echohl WarningMsg | echomsg "GAME OVER!!" | echohl None
        setlocal nomodifiable
        break
      endif
      let r += 1
      let x = 13
    elseif c == 'x' || c == "\r"
      call add(hai, t)
      let hai = sort(hai)
      call s:judge(hai, r)
      setlocal nomodifiable
      break
    endif
  endwhile
endfunction

command! Mahjong :call s:mahjong()
