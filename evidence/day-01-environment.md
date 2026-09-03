# Day 1 환경 확인 기록

- 확인 일시: 2026-08-31 14:30
- 실행 위치: Kibana Dev Tools Console (`http://localhost:5601/app/dev_tools#/console/shell`)
- 실행 요청 파일: `elasticsearch/requests.http`

## 1. Docker 상태

es01, es02, es03과 Kibana 컨테이너 실행 중. setup 컨테이너는 인증서 생성 후 exit 0.

- 판정: 통과

## 2. Kibana 접속

`http://localhost:5601` 로그인, Dev Tools Console 열림.

- 판정: 통과

## 3. `GET /`

| 확인 항목 | 출력 값 |
|---|---|
| version number | `9.5.0` |
| cluster_name | `es-5days-pbl` |
| lucene_version | `10.5.0` |

교재 기준 9.5.0과 동일.

- 판정: 통과

## 4. `GET /_cluster/health`

| 확인 항목 | 출력 값 |
|---|---|
| status | `green` |
| number_of_nodes | `3` |
| unassigned_shards | `0` |

green = primary와 replica 전부 배정됨.

- 판정: 통과

## 5. `GET /_cat/nodes?v`

es01, es02, es03 세 줄. 마스터는 es03(`*`).

- 판정: 통과

## 종합 판정

ES 9.5.0, cluster green, node 3개. 전부 충족.

> 비밀번호, `.env` 실제 값, 토큰은 기록하지 않는다.
