import App from '@/App.vue';
import GlobalLoading from '@/components/GlobalLoading.vue';
import router from '@/router';
import '@/style.css';
import ViewUIPlus from 'view-ui-plus';
import 'view-ui-plus/dist/styles/viewuiplus.css';
import { createApp } from 'vue';

const app = createApp(App);
app.use(router);
app.use(ViewUIPlus);
app.component('GlobalLoading', GlobalLoading);
app.mount('#app');
