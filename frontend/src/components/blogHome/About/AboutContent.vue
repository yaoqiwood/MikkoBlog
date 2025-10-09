<template>
  <div class="about-content">
    <div class="about-card">
      <!-- 个人简介头部 -->
      <div class="about-header">
        <div class="profile-section">
          <div class="profile-avatar">
            <img :src="getFullUrl(userProfile.avatar)" :alt="userProfile.nickname" />
          </div>
          <div class="profile-basic">
            <h1 class="profile-name">{{ userProfile.nickname || 'Mikko' }}</h1>
            <p class="profile-title">LLM应用开发工程师 | 全栈开发工程师</p>
            <p class="profile-subtitle">专注AI技术应用，记录学习与成长</p>
          </div>
        </div>
      </div>

      <!-- 个人介绍 -->
      <div class="about-section">
        <h2 class="section-title">👋 关于我</h2>
        <div class="about-text">
          <p>
            你好！我是一名正在学习 <strong>LLM（大语言模型）应用开发</strong> 的工程师。
            在转型AI领域之前，我是一名经验丰富的 <strong>Java后端</strong> 和
            <strong>Vue前端</strong> 全栈开发工程师。
          </p>
          <p>
            现在，我正致力于重新回到互联网开发的前沿，专注于将传统开发经验与新兴的AI技术相结合，
            探索LLM在实际业务场景中的应用可能性。
          </p>
          <p>这个博客是我学习旅程的记录，我会在这里分享：</p>
          <ul class="about-list">
            <li>🎯 LLM应用开发的学习心得和技术实践</li>
            <li>💻 全栈开发项目的经验总结</li>
            <li>🤔 技术转型过程中的思考和感悟</li>
            <li>📚 新技术的学习笔记和最佳实践</li>
            <li>🚀 开源项目和实验性应用的开发过程</li>
          </ul>
        </div>
      </div>

      <!-- 技术栈 -->
      <div class="about-section">
        <h2 class="section-title">🛠️ 技术栈</h2>
        <div class="tech-stack">
          <div class="tech-category">
            <h3>AI & LLM</h3>
            <div class="tech-tags">
              <span class="tech-tag ai">OpenAI API</span>
              <span class="tech-tag ai">LangChain</span>
              <span class="tech-tag ai">Vector Database</span>
              <span class="tech-tag ai">RAG</span>
              <span class="tech-tag ai">Prompt Engineering</span>
            </div>
          </div>
          <div class="tech-category">
            <h3>后端开发</h3>
            <div class="tech-tags">
              <span class="tech-tag backend">Java</span>
              <span class="tech-tag backend">Spring Boot</span>
              <span class="tech-tag backend">Python</span>
              <span class="tech-tag backend">FastAPI</span>
              <span class="tech-tag backend">MySQL</span>
              <span class="tech-tag backend">Redis</span>
            </div>
          </div>
          <div class="tech-category">
            <h3>前端开发</h3>
            <div class="tech-tags">
              <span class="tech-tag frontend">Vue.js</span>
              <span class="tech-tag frontend">React</span>
              <span class="tech-tag frontend">TypeScript</span>
              <span class="tech-tag frontend">Vite</span>
              <span class="tech-tag frontend">Element Plus</span>
            </div>
          </div>
          <div class="tech-category">
            <h3>DevOps & 工具</h3>
            <div class="tech-tags">
              <span class="tech-tag devops">Docker</span>
              <span class="tech-tag devops">Git</span>
              <span class="tech-tag devops">Linux</span>
              <span class="tech-tag devops">Nginx</span>
              <span class="tech-tag devops">CI/CD</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 学习目标 -->
      <div class="about-section">
        <h2 class="section-title">🎯 当前学习目标</h2>
        <div class="goals-grid">
          <div class="goal-card">
            <div class="goal-icon">🤖</div>
            <h3>LLM应用开发</h3>
            <p>深入学习大语言模型的应用开发，包括API集成、提示工程、RAG系统构建等</p>
          </div>
          <div class="goal-card">
            <div class="goal-icon">🔗</div>
            <h3>AI与传统开发融合</h3>
            <p>探索如何将AI能力无缝集成到现有的业务系统中，提升开发效率和用户体验</p>
          </div>
          <div class="goal-card">
            <div class="goal-icon">📈</div>
            <h3>技术转型</h3>
            <p>从传统全栈开发向AI应用开发转型，保持技术敏感度和学习能力</p>
          </div>
          <div class="goal-card">
            <div class="goal-icon">🌐</div>
            <h3>互联网前沿</h3>
            <p>重新回到互联网开发的前沿，关注新技术趋势和行业最佳实践</p>
          </div>
        </div>
      </div>

      <!-- 联系方式 -->
      <div class="about-section">
        <h2 class="section-title">📬 联系我</h2>
        <div class="contact-grid">
          <div v-if="userProfile.email" class="contact-item">
            <div class="contact-icon">📧</div>
            <div class="contact-info">
              <h4>邮箱</h4>
              <p>{{ userProfile.email }}</p>
            </div>
          </div>
          <div v-if="userProfile.github_url" class="contact-item">
            <div class="contact-icon">🐙</div>
            <div class="contact-info">
              <h4>GitHub</h4>
              <p>{{ userProfile.github_url }}</p>
            </div>
          </div>
          <div v-if="userProfile.website_url" class="contact-item">
            <div class="contact-icon">🌐</div>
            <div class="contact-info">
              <h4>个人网站</h4>
              <p>{{ userProfile.website_url }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 座右铭 -->
      <div v-if="userProfile.motto" class="about-section motto-section">
        <div class="motto-card">
          <div class="motto-icon">💭</div>
          <blockquote class="motto-text">"{{ userProfile.motto }}"</blockquote>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  userProfile: {
    type: Object,
    required: true,
  },
});

// 将相对路径转换为完整URL
const getFullUrl = url => {
  if (!url) return '';

  // 如果是相对路径，转换为完整URL
  if (url.startsWith('/')) {
    return `${window.location.origin}${url}`;
  }

  return url;
};
</script>

<style scoped>
/* 关于我页面样式 */
.about-content {
  padding: 0;
}

.about-card {
  background: white;
  border-radius: 15px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
  overflow: hidden;
  padding: 32px;
}

/* 个人简介头部 */
.about-header {
  margin-bottom: 40px;
  padding-bottom: 30px;
  border-bottom: 2px solid #f0f0f0;
}

.profile-section {
  display: flex;
  align-items: center;
  gap: 24px;
}

.profile-avatar {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  overflow: hidden;
  border: 4px solid #fff;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  flex-shrink: 0;
}

.profile-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.profile-basic {
  flex: 1;
}

.profile-name {
  font-size: 32px;
  font-weight: 700;
  color: #333;
  margin: 0 0 8px 0;
  background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.profile-title {
  font-size: 18px;
  color: #666;
  margin: 0 0 8px 0;
  font-weight: 500;
}

.profile-subtitle {
  font-size: 16px;
  color: #888;
  margin: 0;
  font-style: italic;
}

/* 章节样式 */
.about-section {
  margin-bottom: 40px;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  color: #333;
  margin: 0 0 20px 0;
  padding-bottom: 10px;
  border-bottom: 2px solid #f0f0f0;
  position: relative;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 60px;
  height: 2px;
  background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
}

/* 个人介绍 */
.about-text {
  line-height: 1.8;
  color: #555;
  font-size: 16px;
}

.about-text p {
  margin: 0 0 16px 0;
}

.about-text strong {
  color: #333;
  font-weight: 600;
}

.about-list {
  margin: 20px 0;
  padding-left: 0;
  list-style: none;
}

.about-list li {
  margin: 12px 0;
  padding: 8px 0;
  color: #555;
  font-size: 15px;
  position: relative;
  padding-left: 30px;
}

.about-list li::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 6px;
  height: 6px;
  background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
}

/* 技术栈 */
.tech-stack {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
}

.tech-category {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 20px;
  border: 1px solid #e9ecef;
}

.tech-category h3 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0 0 16px 0;
  text-align: center;
}

.tech-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}

.tech-tag {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 500;
  color: white;
  transition: all 0.3s ease;
}

.tech-tag:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.tech-tag.ai {
  background: linear-gradient(45deg, #ff6b6b, #ee5a24);
}

.tech-tag.backend {
  background: linear-gradient(45deg, #4ecdc4, #44a08d);
}

.tech-tag.frontend {
  background: linear-gradient(45deg, #667eea, #764ba2);
}

.tech-tag.devops {
  background: linear-gradient(45deg, #f093fb, #f5576c);
}

/* 学习目标 */
.goals-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.goal-card {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 12px;
  padding: 24px;
  text-align: center;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.goal-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border-color: #667eea;
}

.goal-icon {
  font-size: 32px;
  margin-bottom: 16px;
}

.goal-card h3 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0 0 12px 0;
}

.goal-card p {
  color: #666;
  line-height: 1.6;
  margin: 0;
  font-size: 14px;
}

/* 联系方式 */
.contact-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 12px;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.contact-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  border-color: #667eea;
}

.contact-icon {
  font-size: 24px;
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  color: white;
  flex-shrink: 0;
}

.contact-info h4 {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin: 0 0 4px 0;
}

.contact-info p {
  color: #666;
  margin: 0;
  font-size: 14px;
}

/* 座右铭 */
.motto-section {
  margin-bottom: 0;
}

.motto-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 32px;
  text-align: center;
  color: white;
  position: relative;
  overflow: hidden;
}

.motto-card::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%,
  100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-20px);
  }
}

.motto-icon {
  font-size: 32px;
  margin-bottom: 16px;
  position: relative;
  z-index: 1;
}

.motto-text {
  font-size: 18px;
  font-style: italic;
  line-height: 1.6;
  margin: 0;
  position: relative;
  z-index: 1;
  font-weight: 500;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .about-card {
    padding: 20px;
  }

  .profile-section {
    flex-direction: column;
    text-align: center;
    gap: 16px;
  }

  .profile-avatar {
    width: 100px;
    height: 100px;
  }

  .profile-name {
    font-size: 28px;
  }

  .profile-title {
    font-size: 16px;
  }

  .section-title {
    font-size: 20px;
  }

  .tech-stack {
    grid-template-columns: 1fr;
  }

  .goals-grid {
    grid-template-columns: 1fr;
  }

  .contact-grid {
    grid-template-columns: 1fr;
  }

  .contact-item {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }
}

@media (max-width: 480px) {
  .about-card {
    padding: 16px;
  }

  .profile-name {
    font-size: 24px;
  }

  .section-title {
    font-size: 18px;
  }

  .about-text {
    font-size: 15px;
  }

  .motto-text {
    font-size: 16px;
  }
}
</style>
