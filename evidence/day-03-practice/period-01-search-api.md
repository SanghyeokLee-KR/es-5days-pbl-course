# 1교시 실습 — Search API 기본

## (공통) 문제 1 — 제공 코드 실행·응답 읽기

다음 요청을 실행하세요.

```http
GET /products/_search
{
  "size": 5,
  "query": { "match_all": {} }
}
```

### 결과 입력

- HTTP 성공 여부: 성공
- `hits.total.value`: 10000
- `hits.hits`에 반환된 문서 수: 5
- 첫 번째 문서의 `_id`: P-00003
- 첫 번째 문서의 `_source` field 3개: `product_id`, `name`, `category`
- `hits.total.value`와 반환 문서 수가 다를 수 있는 이유: 전체 검색 결과는 10000건이지만 `size`를 5로 설정해서 실제 응답에는 5건만 담겼다.

## (공통) 문제 2 — 반환 개수와 field 직접 구현

`products` index의 전체 문서 중 최대 3건만 반환하고, `_source`에는 `product_id`, `name`, `price`, `in_stock`만 포함하는 Search API를 작성하고 실행하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 3,
  "_source": ["product_id", "name", "price", "in_stock"],
  "query": { "match_all": {} }
}
```

### 결과 입력

- 반환 문서 수: 3
- `_source`에 요구하지 않은 field가 포함됐는가: 아니오. 지정한 4개 field만 반환됐다.
- 검증한 문서 ID: P-00003, P-00004, P-00008

## (공통) 문제 3 — 정렬이 포함된 전체 조회 구현

`products` index의 전체 문서 중 최대 10건을 `price`가 낮은 순서로 반환하세요. `_source`에는 `product_id`, `name`, `price`만 포함하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "price"],
  "query": { "match_all": {} },
  "sort": [{ "price": "asc" }]
}
```

### 결과 입력

- 첫 3개 문서의 ID와 price: P-00431(5900원), P-06599(5900원), P-06479(5900원)
- 오름차순 여부: 맞다.
- 두 문서의 price가 같을 때 순서가 고정된다고 말할 수 있는가? 근거: 아니다. 5900원인 문서가 4건인데 정렬 기준은 `price` 하나뿐이다. 같은 가격인 문서끼리의 순서를 정할 두 번째 기준이 없으므로 현재 순서가 항상 유지된다고 볼 수 없다.

## (개인) 문제 4 — 자기 index의 첫 Search API

자기 index의 전체 문서 중 최대 5건을 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 실제 자기 index 이름을 사용합니다.
- `_count`와 `hits.total.value`를 비교합니다.
- `size`와 전체 일치 문서 수를 구분해 설명합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 5,
  "query": { "match_all": {} }
}
```

- 자기 index: `shop-logs`
- `_count`: 1000
- `hits.total.value`: 1000
- 반환 문서 수: 5
- 판정과 근거: 통과. `_count`와 `hits.total.value`가 둘 다 1000으로 나왔다. `size: 5`는 응답에 보여 줄 문서 수만 제한하기 때문에 실제 반환 문서는 5건이다.

## (개인) 문제 5 — 결과 카드 field 설계

자기 서비스에서 검색 결과 카드 한 개를 보여 준다고 가정하세요. 사용자가 클릭 여부를 결정하는 데 필요한 field 3~5개만 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 선택한 field가 자기 mapping과 실제 문서에 존재해야 합니다.
- 식별자, 제목 역할, 판단용 정보가 포함되어야 합니다.
- 불필요한 field를 하나 이상 제외하고 이유를 설명합니다.

### API와 결과 입력

```http
GET /shop-logs/_search
{
  "size": 5,
  "_source": ["log_id", "service_name", "log_level", "message", "duration_ms"],
  "query": { "match_all": {} }
}
```

- 포함한 field와 이유: 로그를 구분할 `log_id`, 발생한 서비스를 볼 `service_name`, 심각도를 확인할 `log_level`, 내용을 바로 알 수 있는 `message`, 처리 시간을 확인할 `duration_ms`를 선택했다.
- 제외한 field와 이유: `logger_name`, `trace_id`, `exception_class`, `http_status`는 상세 화면에서 확인해도 되는 정보라 카드에서는 제외했다.
- 실제 반환 문서 ID: LOG-000001, LOG-000002, LOG-000003, LOG-000004, LOG-000005
- 완료 판정: 통과
