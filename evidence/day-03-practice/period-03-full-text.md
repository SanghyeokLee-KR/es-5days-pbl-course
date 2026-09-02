# 3교시 실습 — 전문 검색 확장

## (공통) 문제 1 — 제공 코드로 여러 field 검색

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "무선 이어폰",
      "fields": ["name", "description"]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 505
- 상위 3개 ID·name: P-00241(SoundLab 프리미엄 무선 이어폰), P-00305(Auralis 실속형 무선 이어폰), P-00529(NeoTech 스마트 무선 이어폰)
- 각 문서가 name·description 중 어디에서 의도와 연결되는가: 세 문서 모두 `name`에 "무선 이어폰"이 들어 있다. `description`은 상품에 대한 일반적인 설명이라 검색어와 직접 연결되지는 않았다.
- 상위 3개 관련/보류/무관 판정: 관련 3건. 세 문서 모두 실제 무선 이어폰 제품이다.

## (공통) 문제 2 — field boost 직접 구현

문제 1과 같은 조건을 유지하되 `name` 일치를 `description`보다 3배 중요하게 보는 Search API를 작성하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "무선 이어폰",
      "fields": ["name^3", "description"]
    }
  }
}
```

### 비교 결과

- 변경 전 상위 3개 ID: P-00241, P-00305, P-00529
- 변경 후 상위 3개 ID: P-00241, P-00305, P-00529 (동일)
- 순위가 달라진 문서와 이유: 상위 3개 순위는 바뀌지 않았다. 세 문서 모두 원래부터 `name`에 "무선 이어폰"이 들어 있어 boost 전에도 점수가 높았기 때문이다. `hits.total.value`도 505건으로 같았는데, boost는 검색되는 문서 수가 아니라 점수와 순위에 영향을 주기 때문이다.
- boost가 사용자 의도에 유리했는가: 이번 상위 3개에서는 차이가 없었다. 그래도 상품명에 검색어가 있는 문서를 설명에만 있는 문서보다 먼저 보여 주려는 의도에는 맞는 설정이라고 생각한다.

## (공통) 문제 3 — 구문 검색 직접 구현

`products` index의 `name`에서 `무선 이어폰`이라는 단어 순서와 인접성을 중요하게 검색하세요. `slop`은 0, 최대 5건으로 구현하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "match_phrase": { "name": { "query": "무선 이어폰", "slop": 0 } }
  }
}
```

### 결과 입력

- `hits.total.value`: 249
- 상위 문서 ID·name: P-00241, P-00305, P-00529 (문제 1과 상위 3개는 같음)
- 문제 1보다 결과가 같거나 줄어든 이유: 결과가 505건에서 249건으로 줄었다. `multi_match`와 달리 `match_phrase`는 `name` 안에서 "무선" 다음에 "이어폰"이 바로 나와야 하므로 어순이 다르거나 두 단어가 떨어진 상품은 제외된다.
- 구문 의도에 맞지 않는 문서가 있는가: 확인한 상위 문서에는 없었다. 모두 상품명에 "무선 이어폰"이 붙어서 들어 있었다.

## (개인) 문제 4 — 여러 text field 검색

자기 프로젝트에서 같은 사용자 검색어가 적용될 수 있는 text field 2개 이상을 선택해 전문 검색을 구현하세요.

### 역할·검증 기준

- 각 field의 서비스 역할을 설명합니다.
- 상위 3개 문서를 사람이 평가합니다.
- 한 field만 필요한 도메인이라면 `match`를 선택하고 그 이유를 적어도 됩니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 5,
  "query": { "match": { "message": "시간 초과" } }
}
```

- 사용자 질문·검색어: "시간 초과가 언급된 로그를 찾고 싶다" / "시간 초과"
- 선택 field와 역할: `message`는 로그 본문이 들어가는 field다. `shop-logs`에서 검색에 사용할 수 있는 text field가 `message` 하나뿐이라 여러 field를 대상으로 하는 `multi_match` 대신 `match`를 사용했다.
- 상위 3개 판정: 관련 3건. LOG-000002, LOG-000016, LOG-000036 모두 시간 초과에 대한 메시지였다.
- query 선택 근거: 실제 mapping에서 text field가 `message` 하나뿐이어서 `match`가 더 적합하다고 판단했다.

## (개인) 문제 5 — boost 또는 phrase 가설 검증

자기 검색에서 field boost 또는 phrase 중 하나를 선택해 기본 요청과 비교하세요.

### 역할·검증 기준

- 같은 index·데이터·검색어·size를 유지합니다.
- 한 요소만 변경합니다.
- 결과가 바뀌지 않아도 실제 결과대로 기록합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 5,
  "query": { "match_phrase": { "message": { "query": "시간 초과", "slop": 0 } } }
}
```

- 선택한 가설: `match_phrase`(`slop: 0`)를 사용하면 `match`보다 결과를 더 정확하게 좁힐 수 있을 것이다.
- 변경 전·후 상위 3개: 변경 전(`match`) LOG-000002/016/036(100건) → 변경 후(`match_phrase`) 0건
- 개선/보류/악화 판정: 악화. 결과를 좁히는 정도가 너무 커서 문서가 하나도 나오지 않았다.
- 판정 근거: `shop-logs`에서는 "초과되었습니다"가 하나의 토큰으로 저장되어 검색어 "초과"와 일치하지 않았다. 그래서 `products`의 "무선 이어폰"에는 잘 작동했던 phrase 검색이 여기서는 0건으로 나왔다. 같은 방법이라도 실제 토큰이 어떻게 나뉘는지에 따라 결과가 달라진다는 것을 확인했다.
