SCIB_METRICS = [
    #"nmi",
    #"ari",
    #"asw",
    "silhouette_batch",
    "pcr_batch",
    "pcr",
    "graph_conn",
    # "kbet",
    # "lisi_label",
    # "lisi_batch",
]


rule scib_all:
    input:
        expand(
            "outputs/{{scenario}}/metrics/{{criteria}}/scib/{{pipeline}}_{metric}.bin",
            metric=SCIB_METRICS,
        ),
        expand(
            "outputs/{{scenario}}/metrics/{{criteria}}/scib/{{pipeline}}_asw_{key}.bin",
            key=config["eval_key"],
        ),
        expand(
            "outputs/{{scenario}}/metrics/{{criteria}}/scib/{{pipeline}}_ari_{key}.bin",
            key=config["eval_key"],
        ),
        expand(
            "outputs/{{scenario}}/metrics/{{criteria}}/scib/{{pipeline}}_nmi_{key}.bin",
            key=config["eval_key"],
        ),
    output:
        output_path="outputs/{scenario}/metrics/{criteria}/{pipeline}_scib.parquet",
    run:
        metrics.scib.concat(*input, **output)


rule clustering:
    input:
        "outputs/{prefix}/{pipeline}.parquet",
    output:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_clusters.h5ad",
    run:
        metrics.scib.cluster(*input, *output)


rule nmi:
    input:
        parquet_path="outputs/{prefix}/{pipeline}.parquet",
    output:
        nmi_path="outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_nmi_{key}.bin",
    params:
        label_key="{key}",
    run:
        metrics.scib.nmi(input.parquet_path, params.label_key, output.nmi_path)


rule ari:
    input:
        parquet_path="outputs/{prefix}/{pipeline}.parquet",
    output:
        ari_path="outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_ari_{key}.bin",
    params:
        label_key="{key}",
    run:
        metrics.scib.ari(input.parquet_path, params.label_key, output.ari_path)


rule asw:
    input:
        parquet_path="outputs/{prefix}/{pipeline}.parquet",
    output:
        asw_path="outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_asw_{key}.bin",
    params:
        label_key="{key}",
    run:
        metrics.scib.asw(input.parquet_path, params.label_key, output.asw_path)


rule silhouette_batch:
    input:
        "outputs/{prefix}/{pipeline}.parquet",
    output:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_silhouette_batch.bin",
    params:
        label_key=config["label_key"],
        batch_key=config["batch_key"] if isinstance(config["batch_key"], str) else config["batch_key"][0],
    run:
        metrics.scib.silhouette_batch(*input, *params, *output)


rule pcr_batch:
    input:
        pre_parquet_path="outputs/{prefix}/mad_int_featselect.parquet",
        post_parquet_path="outputs/{prefix}/{pipeline}.parquet",
    output:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_pcr_batch.bin",
    params:
        batch_key=config["batch_key"] if isinstance(config["batch_key"], str) else config["batch_key"][0],
    run:
        metrics.scib.pcr_batch(*input, *params, *output)


rule pcr:
    input:
        "outputs/{prefix}/{pipeline}.parquet",
    output:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_pcr.bin",
    params:
        batch_key=config["batch_key"] if isinstance(config["batch_key"], str) else config["batch_key"][0],
    run:
        metrics.scib.pcr(*input, *params, *output)


rule il_asw:
    input:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_clusters.h5ad",
    output:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_il_asw.bin",
    params:
        label_key=config["label_key"],
        batch_key=config["batch_key"] if isinstance(config["batch_key"], str) else config["batch_key"][0],
    run:
        metrics.scib.isolated_labels_asw(*input, *params, *output)


rule il_f1:
    input:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_clusters.h5ad",
    output:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_il_f1.bin",
    params:
        label_key=config["label_key"],
        batch_key=config["batch_key"] if isinstance(config["batch_key"], str) else config["batch_key"][0],
    run:
        metrics.scib.isolated_labels_f1(*input, *params, *output)


rule graph_conn:
    input:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_clusters.h5ad",
    output:
        "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_graph_conn.bin",
    params:
        label_key=config["label_key"],
    run:
        metrics.scib.graph_connectivity(*input, *params, *output)


# rule kbet:
#     input:
#         "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_clusters.h5ad",
#     output:
#         "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_kbet.bin",
#     params:
#         label_key=config["label_key"],
#         batch_key=config["batch_key"],
#     run:
#         metrics.scib.kbet(*input, *params, *output)


# rule lisi_label:
#     input:
#         "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_clusters.h5ad",
#     output:
#         "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_lisi_label.bin",
#     params:
#         label_key=config["label_key"],
#     run:
#         metrics.scib.lisi_label(*input, *params, *output)


# rule lisi_batch:
#     input:
#         "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_clusters.h5ad",
#     output:
#         "outputs/{prefix}/metrics/{criteria}/scib/{pipeline}_lisi_batch.bin",
#     params:
#         batch_key=config["batch_key"],
#     run:
#         metrics.scib.lisi_batch(*input, *params, *output)
