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
- 각 문서가 name·description 중 어디에서 의도와 연결되는가: 셋 다 `name`. `description`은 일반 설명이라 연결 안 됨
- 상위 3개 관련/보류/무관 판정: 관련 3건

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
- 순위가 달라진 문서와 이유: 없음. 셋 다 `name`에 "무선 이어폰"이 있어 boost 전에도 상위였음
- boost가 사용자 의도에 유리했는가: 상위 3개는 차이 없음. 설정 방향 자체는 의도에 맞음

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
- 문제 1보다 결과가 같거나 줄어든 이유: 505건 → 249건. `match_phrase`는 "무선" 바로 뒤에 "이어폰"이 와야 해서 어순이 다르면 빠짐
- 구문 의도에 맞지 않는 문서가 있는가: 없음

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
- 선택 field와 역할: `message`(로그 본문). `shop-logs`의 유일한 text field라 `multi_match` 대신 `match`
- 상위 3개 판정: 관련 3건(LOG-000002, LOG-000016, LOG-000036)
- query 선택 근거: text field가 `message` 하나뿐

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

- 선택한 가설: `match_phrase`(`slop: 0`)가 `match`보다 결과를 정확하게 좁힌다
- 변경 전·후 상위 3개: 변경 전(`match`) LOG-000002/016/036(100건) → 변경 후(`match_phrase`) 0건
- 개선/보류/악화 판정: 악화. 0건
- 판정 근거: "초과되었습니다"가 한 토큰으로 저장돼서 검색어 "초과"와 안 맞음
