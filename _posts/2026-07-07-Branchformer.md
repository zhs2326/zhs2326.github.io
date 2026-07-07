---
title: 'Branchformer: Parallel Attention and Convolutional Gating for ASR'
date: 2026-07-07
permalink: /posts/2026/07/blog-post-1/
categories:
  - Automatic Speech Recognition
tags:
  - speech recognition
  - deep learning
  - transformer
excerpt: "My notes on Branchformer, a parallel two-branch alternative to Conformer for ASR encoding."
---

# Branchformer
Branchformer is an encoder architecture for ASR and a follow-up to Conformer. In a Conformer block, multi-head self-attention (MHSA) is followed by a convolution layer so that the model can capture both global and local information. However, this fixed, sequential arrangement may not be optimal. Intuitively, shallow layers might benefit from emphasizing local patterns, while deeper layers might benefit from more global context — yet Conformer applies the same attention-then-convolution recipe at every layer.

To better understand how local and global modeling should interact, and to design a more flexible ASR encoder, Branchformer replaces this sequential design with a two-branch **parallel** architecture: one branch uses MHSA to capture global patterns, while the other uses a convolutional gated MLP (cgMLP) to capture local patterns. Crucially, the two branches are combined by a learnable merge, so their relative importance at each layer becomes something we can directly inspect. Experiments show that Branchformer performs on par with Conformer (and is slightly better or more stable on some datasets), while the two-branch design also makes it easier to build more lightweight and efficient variants.


# Motivation
Conformer combines the strengths of the Transformer and convolution, and achieves better ASR performance than a plain Transformer. It is a stack of Conformer blocks, and within each block MHSA is followed by a convolution. This naturally raises the question of whether the fixed MHSA→conv→MHSA→conv… pattern is optimal for speech recognition. Forcing every layer to first attend globally and then convolve locally may make the model harder to optimize, and it also fixes the order in which local and global information are combined.

Moreover, a sequential architecture like Conformer is hard to *diagnose*: because the two operations are entangled in a fixed sequence, it is difficult to tell how much each contributes at a given depth. A parallel architecture makes this analysis much easier. If one branch is dedicated to local modeling and the other to global modeling, we can read off the weights used to merge them and directly quantify how important each branch is at each stage of the network.


# Architecture
The overall pipeline of Branchformer is the same as Conformer: the audio is first turned into a log-mel spectrogram, passed through a convolutional subsampling module, added with positional encoding, and then fed into a stack of encoder blocks.

![Overall Branchformer encoder architecture (left) and the two-branch encoder block (right)]({{ site.baseurl }}/images/posts/branchformer/model_architecture.png)
*Overall encoder architecture (a) and the Branchformer encoder block (b). Each block runs a self-attention branch (global context) and a convolutional-gating MLP branch (local context) in parallel, then merges them. (Figure 2 from the Branchformer paper.)*

The encoder block is where Branchformer diverges from Conformer. As its name suggests, each block has two parallel branches that share the same input. Notably — and unlike Conformer — the block has **no separate feed-forward (FFN) module**; the two linear (channel-projection) layers inside the cgMLP branch already play that role, so the block stays comparatively simple.

**Branch 1 — global (attention):**
Input → Layer Norm → MHSA (with relative positional encoding) → Dropout

The relative positional encoding is the same style used in Transformer-XL / Conformer, which lets attention generalize better across sequence positions.

**Branch 2 — local (cgMLP):**
Input → Layer Norm → Channel Projection to a higher dim → GELU → Convolutional Spatial Gating Unit (CSGU) → Channel Projection back down → Dropout

This branch is a convolutional gated MLP (cgMLP). The activation after the first channel projection is **GELU** (a plain non-linearity), not a GLU — the actual gating happens inside the CSGU. The CSGU works as follows: the (high-dimensional) features are split in half along the channel dimension into two parts; one part is passed through a Layer Norm and a depth-wise convolution along the time axis, and the result is used to gate (element-wise multiply) the other part. The depth-wise convolution is what injects local, temporal context, and the multiplicative gate lets the branch modulate features position-by-position at linear cost in sequence length.

**Merge & project:**
The two branch outputs are combined and projected back to the input dimension. The paper studies two merge strategies:
- **Concatenation + linear projection** — concatenate the two outputs along the channel dimension and project down. This is the default and gives the best accuracy.
- **Weighted average** — learn a scalar weight per branch (via a softmax) and take a weighted sum. This is slightly worse in accuracy, but it is what enables the layer-wise importance analysis below, since the learned weights directly express how much each branch matters.


# Performance
Across benchmarks, Branchformer achieves results comparable to Conformer on ASR. On LibriSpeech it roughly matches a same-size Conformer (around 2.4% / 5.5% WER on test-clean / test-other without an external LM), and on some datasets it is even slightly better or more stable to train — for example a lower CER on AISHELL, and it trains successfully on Speech Commands where the Conformer baseline diverged. The takeaway is not that Branchformer dramatically beats Conformer in accuracy — it does not — but that it reaches comparable quality with a simpler, more interpretable, and more flexible design.

![LibriSpeech WER results comparing Branchformer with Conformer and other baselines]({{ site.baseurl }}/images/posts/branchformer/exp_result3.png)
*On LibriSpeech, Branchformer matches the same-size Conformer baseline on test-clean / test-other. (Table 3 from the Branchformer paper.)*

![AISHELL Mandarin CER results comparing Branchformer with Conformer and other baselines]({{ site.baseurl }}/images/posts/branchformer/exp_result1.png)
*On the AISHELL Mandarin task, Branchformer edges out the Conformer baseline in CER. (Table 1 from the Branchformer paper.)*

![Switchboard WER results comparing Branchformer with Conformer and other baselines]({{ site.baseurl }}/images/posts/branchformer/exp_result2.png)
*On Switchboard, Branchformer is on par with Conformer. (Table 2 from the Branchformer paper.)*


# Layer-wise Analysis of Global/Local Branches
This is the most interesting part of the paper, and in my opinion the biggest benefit of Branchformer: because the two branches are merged with learnable weights, we can read those weights off and see how important the global and local branches are at each depth. The pattern is not perfectly clean, but it is far from random — the early layers tend to use both branches fairly evenly, the middle-to-late layers are increasingly dominated by the global (attention) branch, and the final layers swing back toward the local (cgMLP) branch. This lines up with the intuition that the model first builds up broad context and then re-focuses on local detail before producing outputs.

![Visualization of per-layer attention and cgMLP branch weights across datasets and depths]({{ site.baseurl }}/images/posts/branchformer/layer_analysis.png)
*Learned branch weights at each layer, from the weighted-average merge. Early layers interleave the two branches, while deeper layers tend to be dominated by consecutive global (attention) then local (cgMLP) blocks. (Figure 5 from the Branchformer paper.)*

Another noteworthy finding is that the *diagonality* of the attention maps decreases in Branchformer. Diagonality measures how much attention concentrates on nearby positions, so lower diagonality means MHSA is attending more globally. In other words, once a dedicated convolutional branch is handling local patterns, the attention branch is freed up to specialize in long-range, global relationships (recall that in principle MHSA can attend either locally or globally). This is exactly the kind of clean division of labor that the parallel design was hoping to encourage.

![Per-layer diagonality of self-attention, comparing Transformer and Branchformer]({{ site.baseurl }}/images/posts/branchformer/diagonality.png)
*Diagonality of self-attention at each encoder layer. Branchformer (blue) stays consistently below the Transformer (orange), i.e. its attention concentrates less on neighboring positions and attends more globally. (Figure 6 from the Branchformer paper.)*


# Efficiency and Lightweight Variants
The parallel design also opens the door to cheaper models, which is where the "lightweight" benefit mentioned earlier comes in. Because the local branch (cgMLP) has linear complexity in sequence length while the attention branch is quadratic, the two can be traded off explicitly. The paper explores a *branch dropout* strategy: by randomly dropping the attention branch during training, the same model can later be run either with both branches (full quality, quadratic cost) or with the cgMLP branch alone (linear cost, small accuracy drop) — without retraining. The attention branch can also be swapped for a cheaper linear-time attention variant, again with only a minor degradation. This flexibility to dial the speed–accuracy trade-off at inference time is much harder to achieve in a tightly-coupled sequential block.


# Conclusion
In my opinion, Branchformer is a great piece of work. It identifies a possible weakness in Conformer's fixed MHSA→conv→MHSA→conv… pattern, and instead of just proposing yet another architecture, it designs clean experiments that let us actually *see* how local and global modeling should be combined across depth. On top of that, its parallel structure is more interpretable and makes it far easier to build efficient, adjustable ASR encoders. It is a good example of a paper whose main contribution is understanding, not just a better number.