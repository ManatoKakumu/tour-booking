import boto3

ecs = boto3.client("ecs")
ecr = boto3.client("ecr")

def handler(event, context):
    service_arn = event["resources"][0]
    event_name = event["detail"]["eventName"]

    _, cluster_name, service_name = service_arn.rsplit("/", 2)

    if event_name == "SERVICE_DEPLOYMENT_COMPLETED":
        repository_name, image_tag = get_current_image(cluster_name, service_name)
        try:
            old_digest = get_digest(repository_name, "current")
            add_tag(repository_name, "current", "success-" + old_digest.split(":")[-1][:12])
            remove_tag(repository_name, "current")
        except IndexError:
            pass  # current タグがまだ存在しない(初回デプロイ)場合はスキップ
        add_tag(repository_name, image_tag, "current")
    elif event_name == "SERVICE_DEPLOYMENT_FAILED":
        deployment_id = event["detail"]["deploymentId"]
        repository_name, image_tag = get_deployment_image(cluster_name, service_name, deployment_id)
        add_tag(repository_name, image_tag, "fail-" + image_tag)
    else:
        # IN_PROGRESSなど、無視してよいイベント
        return

    return {"status": "ok"}

def get_current_image(cluster_name, service_name):
    services = ecs.describe_services(cluster=cluster_name, services=[service_name])
    task_def_arn = services["services"][0]["taskDefinition"]

    task_def = ecs.describe_task_definition(taskDefinition=task_def_arn)
    image_uri = task_def["taskDefinition"]["containerDefinitions"][0]["image"]

    repository_name, image_tag = image_uri.split("/")[-1].split(":")
    return repository_name, image_tag

def get_digest(repository_name, tag):
    image = ecr.batch_get_image(
        repositoryName=repository_name,
        imageIds=[{"imageTag": tag}],
    )["images"][0]
    return image["imageId"]["imageDigest"]

def add_tag(repository_name, existing_tag, new_tag):
    # 既存のイメージの中身(マニフェスト)を取得する
    image = ecr.batch_get_image(
        repositoryName=repository_name,
        imageIds=[{"imageTag": existing_tag}],
    )["images"][0]

    # 取得したマニフェストを使って、新しいタグとして登録する
    # (画像データ自体は再アップロードせず、同じ中身に別のタグを貼るだけ)
    ecr.put_image(
        repositoryName=repository_name,
        imageTag=new_tag,
        imageManifest=image["imageManifest"],
        imageManifestMediaType=image["imageManifestMediaType"],
    )

def remove_tag(repository_name, tag):
    ecr.batch_delete_image(
        repositoryName=repository_name,
        imageIds=[{"imageTag": tag}],
    )

def get_deployment_image(cluster_name, service_name, deployment_id):
    services = ecs.describe_services(cluster=cluster_name, services=[service_name])
    for deployment in services["services"][0]["deployments"]:
        if deployment["id"] == deployment_id:
            task_def_arn = deployment["taskDefinition"]
            break

    task_def = ecs.describe_task_definition(taskDefinition=task_def_arn)
    image_uri = task_def["taskDefinition"]["containerDefinitions"][0]["image"]
    return image_uri.split("/")[-1].split(":")
