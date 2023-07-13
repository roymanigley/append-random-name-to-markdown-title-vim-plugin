set nocompatible

let g:names=["Foxtrott", "Uniform", "Charlie", "Kilo"]
let g:random_dot_org_create_mapping_script=<< END
#!/bin/bash
line_count=$(cat /tmp/names | wc -l)

curl -X POST "https://api.random.org/json-rpc/4/invoke" \
    -H "Content-Type: application/json" \
    --data "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"generateIntegers\",
    \"params\": {
        \"apiKey\": \"$RANDOM_DOT_ORG_API_KEY\",
        \"n\": $line_count,
        \"min\": 1,
        \"max\": $line_count,
        \"replacement\": false
    },
    \"id\": 42
}" 2>/dev/null \
    | jq '.result.random.data' \
    | sed '1,1d' \
    | sed '$d' \
    | sed 's/^\s\+\|,//g' \
    > /tmp/random_mapping
END

function RandomMarkdownAppender#randomizeRandomDotOrg()
    let API_KEY=system('echo $RANDOM_DOT_ORG_API_KEY')
    echo $API_KEY
    if !API_KEY
        echo 'you have to set the API Key form random.org as environment variable'
        echo 'export RANDOM_DOT_ORG_API_KEY=***************************'
        return
    endif
    call system('rm /tmp/names')
    for name in g:names
        call system('echo ' . name . ' >> /tmp/names')
    endfor
    call system(join(g:random_dot_org_create_mapping_script, "\n"))
    let cnt=0
    let names_cnt=len(g:names)
    g/^# /let cnt=cnt+1
    for i in range(0, cnt-1)
        let random_mapping_index= i % names_cnt + 1
        let name_index=system('sed "' . random_mapping_index . 'q;d" /tmp/random_mapping')
        /^# 
        exe "normal A (" . g:names[name_index - 1] . ")"
    endfor
endfunction

function RandomMarkdownAppender#randomizeSimple()
    let names_concantinated = join(g:names, ' ')
    let random_ordered_names = system('shuf -e ' . names_concantinated)
    let random_ordered_names_list = split(random_ordered_names, "\n")
    let cnt=0
    let names_cnt=len(random_ordered_names_list)
    g/^# /let cnt=cnt+1
    for i in range(0, cnt-1)
        let name_index= i % names_cnt
        let name=random_ordered_names_list[name_index]
        /^# 
        exe "normal A (" . trim(name) . ")"
    endfor
endfunction


" nnoremap <C-t> :call RandomMarkdownAppender#randomizeSimple()<CR>

" API_KEY_REQUIRED for RandomMarkdownAppender#randomizeRandomDotOrg
" export RANDOM_DOT_ORG_API_KEY=***************************
" nnoremap <C-P> :call RandomMarkdownAppender#randomizeRandomDotOrg()<CR>
