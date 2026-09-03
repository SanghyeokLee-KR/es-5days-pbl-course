# 2교시 실습 — term과 match

## (공통) 문제 1 — 제공 코드로 정확 조건 확인

```http
GET /products/_search
{
  "size": 5,
  "query": { "term": { "category": "전자기기" } }
}
```

### 결과 입력

- `hits.total.value`: 1250
- 상위 3개 문서 ID: P-00009, P-00025, P-00081
- 상위 3개 문서의 category: 전자기기, 전자기기, 전자기기
- 모든 확인 문서가 정확 조건을 만족하는가: 예
- `term`을 선택한 mapping 근거: `category`가 `keyword`라 분석 없이 그대로 저장됨

## (공통) 문제 2 — text 전문 검색 직접 구현

`products` index에서 상품명 `name`에 `무선`이라는 검색 의도가 있는 문서를 찾으세요. text 전문 검색에 적합한 query를 선택해 최대 5건을 반환하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": { "match": { "name": "무선" } }
}
```

### 결과 입력

- 선택한 query와 이유: `match`. `name`이 `text` type이라
- `hits.total.value`: 505
- 상위 3개 ID·name: P-00025(MobiCore 컴팩트 무선 이어폰), P-00042, P-00129

## (공통) 문제 3 — 부적절한 조합 비교

같은 `name` field와 `무선` 검색어에 `term` query를 사용한 API를 직접 작성하세요. 문제 2와 결과를 비교하고, 차이를 mapping 또는 분석된 token 관점에서 설명하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": { "term": { "name": "무선" } }
}
```

### 비교 결과

- 문제 2 total / 문제 3 total: 505 / 505
- 공통으로 나온 문서 ID: P-00025, P-00042, P-00129 (상위 3개 완전히 동일)
- 달라진 이유: 안 달라짐. 검색어 "무선"이 분석된 토큰과 같아서 `term`으로도 같은 문서가 걸림
- `term`은 text에서 항상 0건인가? 실제 근거: 아니오. `match`와 `term` 모두 505건. 저장된 토큰과 검색어가 같으면 `term`으로도 검색됨

## (개인) 문제 4 — 자기 정확 조건 검색

자기 mapping에서 값 전체가 정확히 일치해야 하는 `keyword` 또는 `boolean` field 하나를 선택해 정확 조건 검색을 구현하세요.

### 역할·검증 기준

- 실제 존재하는 field와 값을 사용합니다.
- 반환 문서의 `_source`에서 조건을 직접 확인합니다.
- 왜 전문 검색이 아니라 정확 비교인지 설명합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 5,
  "query": { "term": { "log_level": "ERROR" } }
}
```

- field / type / 값: `log_level` / `keyword` / `"ERROR"`
- 사용자 질문: 심각한 로그(ERROR)만 보고 싶다
- 상위 3개 ID와 실제 값: LOG-000002(ERROR), LOG-000008(ERROR), LOG-000027(ERROR)
- 통과/실패와 근거: 통과. 확인한 문서 `log_level`이 전부 `ERROR`

## (개인) 문제 5 — 자기 전문 검색

자기 mapping의 `text` field 하나와 사용자가 입력할 검색어를 정해 전문 검색 API를 구현하세요.

### 역할·검증 기준

- field가 실제 `text`인지 mapping으로 확인합니다.
- 상위 3개 결과를 관련/보류/무관으로 판정합니다.
- 정확 조건 문제와 query 선택 이유가 달라야 합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 5,
  "query": { "match": { "message": "재시도" } }
}
```

- field / type / 검색어: `message` / `text` / `"재시도"`
- 상위 3개 ID: 없음 (0건)
- 관련/보류/무관과 이유: 판정 불가(0건). 실제 문장은 "재시도가"인데 `재시도가` 한 토큰으로 저장돼서 검색어 `재시도`와 안 맞음(`evidence/day-02-data.md` 5절)
- 완료 판정: 보류
