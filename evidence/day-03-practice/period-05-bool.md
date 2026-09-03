# 5교시 실습 — bool 검색

## (공통) 문제 1 — 제공 코드로 must·filter 확인

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [{ "match": { "name": "무선" } }],
      "filter": [
        { "term": { "category": "전자기기" } },
        { "term": { "in_stock": true } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 74
- 상위 3개 ID·name: P-00025(MobiCore 컴팩트 무선 이어폰), P-00129, P-00369
- 세 filter의 실제 값: 전부 category=전자기기, in_stock=true, price 50000~200000 범위 안
- must와 filter의 역할 차이: `must`(match)는 관련도 점수를 계산해 검색어와의 연관성을 반영하고, `filter`는 점수 계산 없이 조건 통과 여부만 본다(예/아니오). filter만으로는 "무선"이라는 단어가 있는지 못 걸러내고, must가 있어야 텍스트 의도가 반영된다.

## (공통) 문제 2 — 조건 제거 실험 직접 구현

문제 1의 요청에서 `in_stock` filter만 제거한 API를 작성하세요. 다른 조건은 바꾸지 마세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [{ "match": { "name": "무선" } }],
      "filter": [
        { "term": { "category": "전자기기" } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 비교 결과

- 변경 전 total / 변경 후 total: 74 / 83
- 새로 포함된 문서 ID·in_stock: P-00457, P-00521 등 — `in_stock=false`(품절)인 무선 전자기기 9건이 새로 포함됐다.
- 변화가 없다면 데이터 근거: 해당 없음(변화 있음)
- 제거한 조건의 역할: `in_stock=true` filter가 "구매 가능한 상품만" 보이게 좁히는 역할을 했다. 제거하니 품절 상품까지 섞여 들어왔다.

## (공통) 문제 3 — should 조건 직접 구현

category가 `전자기기`인 문서 중 `name`에 `무선`이 있거나 `in_stock=true`인 조건을 최소 하나 만족하도록 bool API를 작성하세요. `minimum_should_match`를 명시하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [{ "term": { "category": "전자기기" } }],
      "should": [
        { "match": { "name": "무선" } },
        { "term": { "in_stock": true } }
      ],
      "minimum_should_match": 1
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 1097
- 무선이지만 품절인 문서 존재 여부: 있음 — should 조건이라 `in_stock` 여부와 무관하게 "무선"이면 포함된다.
- 무선이 아니지만 재고가 있는 문서 존재 여부: 있음 — 전자기기 카테고리에서 재고 있는 상품이면 이름에 "무선"이 없어도 포함된다.
- should 조건 판정: 정상 동작 — 두 조건 중 하나만 만족해도(`minimum_should_match:1`) 포함되어, filter만 쓴 문제 1(74건)이나 문제 2(83건)보다 훨씬 넓은 1097건이 나왔다.

## (개인) 문제 4 — 자기 bool 검색

자기 사용자 질문 하나를 검색 의도와 정확 조건으로 분해해 bool 요청을 구현하세요.

### 역할·검증 기준

- must 0~1개, filter 2개 이상을 사용합니다.
- 각 field와 query 선택 이유를 mapping type으로 설명합니다.
- 반환 문서 3개 이상을 실제 값으로 검증합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [{ "match": { "message": "시간 초과" } }],
      "filter": [
        { "term": { "service_name": "payment-api" } },
        { "range": { "duration_ms": { "gte": 2000 } } }
      ]
    }
  }
}
```

- 사용자 질문: 결제 서비스에서 시간 초과된 로그 중 처리 시간이 2초 이상인 것을 보고 싶다.
- must와 이유: `match: message "시간 초과"` — 사용자가 "시간 초과"라는 자연어 의도를 검색하므로 관련도 기반 검색이 필요하다.
- filter 2개와 이유: `service_name=payment-api`(keyword 정확 조건), `duration_ms>=2000`(integer 범위 조건) — 둘 다 예/아니오로만 판단되면 되므로 filter가 적합하다.
- 실제 검증 결과: `hits.total.value: 19`, 상위 문서(LOG-000002, LOG-000061, LOG-000083)의 `service_name`이 전부 payment-api이고 `duration_ms`가 2000 이상임을 확인했다.

## (개인) 문제 5 — 조건 역할 검증

개인 문제 4에서 filter 하나를 제거하고 전후 결과를 비교하세요. 추가로 원래 조건에서 제외되어야 하는 문서 1개를 독립 요청으로 확인하세요.

### 역할·검증 기준

- 한 번에 filter 하나만 제거합니다.
- 새로 포함된 문서의 실제 값을 확인합니다.
- 제외 문서는 원래 bool 결과에 포함되지 않아야 합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [{ "match": { "message": "시간 초과" } }],
      "filter": [{ "term": { "service_name": "payment-api" } }]
    }
  }
}
```

- 제거한 filter: `duration_ms>=2000`
- 전/후 total: 19 / 27
- 새로 포함된 ID와 값: duration_ms가 2000 미만인 payment-api 타임아웃 로그 8건이 추가로 포함됐다(LOG-000188 등).
- 제외 확인 ID와 근거: `service_name=order-api`인 문서(예: LOG-000001)는 원래 bool 결과의 filter 조건(`service_name=payment-api`)만으로 이미 배제된다. `term: service_name=order-api`로 별도 조회해 order-api 문서들이 실제로 존재함을 확인했고, 그 문서들이 원래 bool 결과에 없다는 것으로 filter의 배제 역할을 검증했다.
