#!/usr/bin/env python3
"""
测试 posts 接口的联表查询功能
"""
import requests
import json

def test_posts_api():
    """测试 posts 接口"""
    base_url = "http://localhost:8000/api"

    # 测试获取文章列表
    url = f"{base_url}/posts/?page=1&limit=10&is_visible=true&is_deleted=false"

    try:
        response = requests.get(url)
        print(f"状态码: {response.status_code}")

        if response.status_code == 200:
            data = response.json()
            print(f"返回文章数量: {len(data)}")

            if data:
                # 显示第一篇文章的详细信息
                first_post = data[0]
                print("\n第一篇文章信息:")
                print(f"ID: {first_post.get('id')}")
                print(f"标题: {first_post.get('title')}")
                print(f"作者: {first_post.get('user_nickname')}")
                print(f"观看数: {first_post.get('view_count', 0)}")
                print(f"点赞数: {first_post.get('like_count', 0)}")
                print(f"分享数: {first_post.get('share_count', 0)}")
                print(f"评论数: {first_post.get('comment_count', 0)}")

                # 检查是否包含统计字段
                stats_fields = ['view_count', 'like_count', 'share_count', 'comment_count']
                missing_fields = [field for field in stats_fields if field not in first_post]

                if missing_fields:
                    print(f"❌ 缺少统计字段: {missing_fields}")
                else:
                    print("✅ 所有统计字段都存在")
            else:
                print("没有文章数据")
        else:
            print(f"请求失败: {response.text}")

    except requests.exceptions.ConnectionError:
        print("❌ 无法连接到服务器，请确保后端服务正在运行")
    except Exception as e:
        print(f"❌ 测试失败: {e}")

if __name__ == "__main__":
    test_posts_api()
