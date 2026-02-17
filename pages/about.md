---
layout: page
title: About
permalink: /about/
weight: 3
---

# **About Me**

Hi I am **{{ site.author.name }}** :wave:,<br>


I'm a Site Reliability Engineer with strong DevOps expertise and a passion for cloud infrastructure, automation, and continuous improvement. I specialize in Kubernetes, Terraform, AWS, and Azure technologies, with experience in building scalable systems, optimizing costs, and implementing observability solutions. Beyond infrastructure, I have a solid foundation in full-stack development and a growing interest in Data Science and Cybersecurity.

<p class="text-center">
{% include elements/button.html link="/assets/resume/OnePageResume.pdf" text="Download Resume (PDF)" style="success" %}
</p>

<div class="row">
{% include about/skills.html source=site.data.skills %}
</div>

## Professional Experience

<div class="row">
{% include about/timeline.html title="Professional Experience" source=site.data.professional-experience %}
</div>

## Education

<div class="row">
{% include about/timeline.html title="Education" source=site.data.timeline %}
</div>